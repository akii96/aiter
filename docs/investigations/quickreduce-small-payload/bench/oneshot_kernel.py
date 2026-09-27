CPP = r'''
void fanout_only(long inp,long peers,long nbytes,long rank_,long world_,long slice_b,long grid);
void oneshot(long inp,long out,long peers,long mybuf,long nbytes,long rank_,long world_,long slice_b,long color,long grid,long inv,long mode);
void empty_k(long g);
long enable_peer(long p);
'''
HIP = r'''
#include <torch/extension.h>
#include <hip/hip_runtime.h>
#include <hip/hip_bf16.h>
typedef int __attribute__((ext_vector_type(4))) i32x4;
// FIXED flag region: must NOT depend on grid, or a small-grid run's inbox
// writes land inside a later large-grid run's flag area (false handshake / hang).
#define FIXED_FB (1024*8*4)
#define WD_MAX 800000000

__global__ void empty_kk(){}
void empty_k(long g){ empty_kk<<<(int)g,256>>>(); }
long enable_peer(long p){ return (long)hipDeviceEnablePeerAccess((int)p,0); }
__device__ __forceinline__ void nt16(long a,i32x4 v){ __builtin_nontemporal_store(v,(i32x4*)a); }
__device__ __forceinline__ long fo(long bid,long src,int w){ return (bid*w+src)*4; }
__device__ __forceinline__ long io(long bid,long src,int w,long sb){ return FIXED_FB+(bid*(long)w+src)*sb; }

__global__ void fanout_k(const i32x4* __restrict__ in,const long* __restrict__ peers,
                         long n16,long r,int w,long s16){
  long bid=blockIdx.x,tid=threadIdx.x,nt=blockDim.x,base=bid*s16,sb=s16*16;
  for(long j=base+tid;j<base+s16&&j<n16;j+=nt){
    i32x4 v=in[j];
    for(int z=0;z<w;z++) nt16(peers[z]+io(bid,r,w,sb)+(j-base)*16,v);
  }
}
void fanout_only(long in,long peers,long nb,long r,long w,long sb,long g){
  fanout_k<<<(int)g,256>>>((const i32x4*)in,(const long*)peers,nb/16,r,(int)w,sb/16);
}
template<int INV,int MODE>
__global__ void oneshot_k(const i32x4* __restrict__ in,i32x4* __restrict__ out,
                          const long* __restrict__ peers,long mybuf,long n16,
                          long r,int w,long s16,int color){
  long bid=blockIdx.x,tid=threadIdx.x,nt=blockDim.x,base=bid*s16,sb=s16*16;
  for(long j=base+tid;j<base+s16&&j<n16;j+=nt){
    i32x4 v=in[j];
    for(int z=0;z<w;z++) nt16(peers[z]+io(bid,r,w,sb)+(j-base)*16,v);
  }
  __builtin_amdgcn_s_waitcnt(0x0070);  // vmcnt(0): THIS wave's NT payload has landed
  __syncthreads();                      // join all waves: vmcnt is per-wave
  if(tid<w) __atomic_store_n((int*)(peers[tid]+fo(bid,r,w)),color,__ATOMIC_RELEASE);
  if(tid<w){
    volatile int* f=(volatile int*)(mybuf+fo(bid,tid,w));
    long sp=0;
    while(__atomic_load_n((int*)f,__ATOMIC_ACQUIRE)!=color){
      if(INV) asm volatile("buffer_inv sc1":::"memory");
      if(++sp>WD_MAX) return;   // watchdog: bail rather than hang the node
    }
  }
  __syncthreads();
  if(MODE==0) return;
  for(long j=base+tid;j<base+s16&&j<n16;j+=nt){
    float acc[8];
    #pragma unroll
    for(int e=0;e<8;e++) acc[e]=0.f;
    for(int s=0;s<w;s++){
      i32x4 v=*(const i32x4*)(mybuf+io(bid,s,w,sb)+(j-base)*16);
      const __hip_bfloat16* b=(const __hip_bfloat16*)&v;
      #pragma unroll
      for(int e=0;e<8;e++) acc[e]+=__bfloat162float(b[e]);
    }
    i32x4 o; __hip_bfloat16* ob=(__hip_bfloat16*)&o;
    #pragma unroll
    for(int e=0;e<8;e++) ob[e]=__float2bfloat16(acc[e]);
    out[j]=o;
  }
}
void oneshot(long in,long out,long peers,long mybuf,long nb,long r,long w,long sb,
             long color,long g,long inv,long mode){
  long n16=nb/16,s16=sb/16;
  if(inv&&mode)       oneshot_k<1,1><<<(int)g,256>>>((const i32x4*)in,(i32x4*)out,(const long*)peers,mybuf,n16,r,(int)w,s16,(int)color);
  else if(!inv&&mode) oneshot_k<0,1><<<(int)g,256>>>((const i32x4*)in,(i32x4*)out,(const long*)peers,mybuf,n16,r,(int)w,s16,(int)color);
  else if(inv&&!mode) oneshot_k<1,0><<<(int)g,256>>>((const i32x4*)in,(i32x4*)out,(const long*)peers,mybuf,n16,r,(int)w,s16,(int)color);
  else                oneshot_k<0,0><<<(int)g,256>>>((const i32x4*)in,(i32x4*)out,(const long*)peers,mybuf,n16,r,(int)w,s16,(int)color);
}
'''
