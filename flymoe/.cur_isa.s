	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast
	.p2align	8
	.type	flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast,@function
flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast:
	s_load_dwordx4 s[0:3], s[4:5], 0x20
	s_mov_b32 s14, 4
	v_readfirstlane_b32 s20, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s13, s3, 0xffff
	s_mov_b32 s3, 0x27000
	s_mov_b32 s12, s2
	s_mov_b32 s15, s3
	buffer_load_dword v1, off, s[12:15], 0
	s_waitcnt vmcnt(0)
	v_readfirstlane_b32 s2, v1
	s_mul_i32 s2, s2, 12
	s_cmp_ge_i32 s8, s2
	s_cbranch_scc1 .LBB0_198
	s_ashr_i32 s6, s2, 31
	s_lshr_b32 s6, s6, 29
	s_add_i32 s6, s2, s6
	s_lshr_b32 s44, s20, 6
	s_lshr_b32 s34, s20, 8
	s_bfe_u32 s35, s20, 0x20006
	s_ashr_i32 s9, s6, 3
	s_and_b32 s12, s6, -8
	s_cmp_lg_u32 s2, s12
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s2, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[6:7], s[10:11], s[6:7]
	s_subb_u32 s6, s9, 0
	s_ashr_i32 s7, s8, 31
	s_lshr_b32 s7, s7, 29
	s_add_i32 s7, s8, s7
	s_ashr_i32 s10, s7, 3
	s_and_b32 s7, s7, -8
	s_sub_i32 s2, s2, s12
	s_sub_i32 s9, s8, s7
	s_min_i32 s2, s9, s2
	s_cmp_lg_u32 s8, s7
	s_mul_i32 s11, s6, s9
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s8, 0
	s_cselect_b64 s[8:9], -1, 0
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_subb_u32 s6, s10, 0
	s_add_i32 s2, s6, s2
	s_add_i32 s16, s2, s11
	s_mul_hi_i32 s2, s16, 0x2aaaaaab
	s_lshr_b32 s6, s2, 31
	s_ashr_i32 s2, s2, 1
	s_add_i32 s2, s2, s6
	s_mul_i32 s17, s2, 12
	s_cmp_lg_u32 s16, s17
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s16, 0
	s_cselect_b64 s[8:9], -1, 0
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_subb_u32 s6, s2, 0
	s_lshl_b32 s6, s6, 4
	s_and_b32 s1, s1, 0xffff
	s_mov_b32 s2, -1
	v_mov_b32_e32 v1, s6
	buffer_load_dwordx3 v[2:4], v1, s[0:3], 0 offen
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_load_dwordx4 s[24:27], s[4:5], 0x30
	s_load_dwordx2 s[6:7], s[4:5], 0x50
	s_sub_i32 s21, s16, s17
	v_bfe_u32 v1, v0, 2, 4
	s_waitcnt lgkmcnt(0)
	s_and_b32 s1, s9, 0xffff
	s_and_b32 s25, s25, 0xffff
	s_lshl_b32 s26, s7, 2
	s_mov_b32 s27, s3
	v_lshlrev_b32_e32 v8, 4, v0
	v_lshlrev_b32_e32 v9, 1, v0
	v_bitop3_b32 v8, v8, 48, v9 bitop3:0x48
	v_mov_b32_e32 v9, s6
	s_mov_b32 s19, s3
	s_waitcnt vmcnt(0)
	v_readfirstlane_b32 s0, v2
	s_mul_i32 s9, s0, 0x900000
	s_mul_hi_i32 s2, s0, 0x900000
	s_add_u32 s16, s9, s12
	s_addc_u32 s2, s2, s13
	s_mul_hi_i32 s18, s0, 0x90000
	s_mul_i32 s0, s0, 0x90000
	s_and_b32 s17, s2, 0xffff
	s_add_u32 s12, s0, s14
	s_addc_u32 s13, s18, s15
	s_lshl_b32 s0, s44, 4
	v_readfirstlane_b32 s33, v3
	v_or_b32_e32 v3, s0, v1
	s_addk_i32 s0, 0x80
	v_add_lshl_u32 v2, s33, v3, 2
	v_or_b32_e32 v6, s0, v1
	buffer_load_dword v5, v2, s[24:27], 0 offen
	v_add_lshl_u32 v1, s33, v6, 2
	buffer_load_dword v7, v1, s[24:27], 0 offen
	s_lshl_b32 s9, s21, 4
	s_lshl_b32 s22, s35, 2
	v_and_b32_e32 v2, 63, v0
	v_readfirstlane_b32 s25, v4
	s_lshr_b32 s20, s20, 7
	s_or_b32 s22, s9, s22
	v_lshlrev_b32_e32 v1, 4, v2
	s_or_b32 s20, s20, 1
	s_mul_i32 s22, s22, 0xc000
	v_cmp_gt_i32_e32 vcc, s25, v3
	s_movk_i32 s14, 0xc00
	s_mul_i32 s15, s34, 0x18000
	s_mul_i32 s20, s20, 0xc000
	v_or_b32_e32 v4, s22, v1
	s_mul_i32 s2, s6, 0xc00
	s_lshl_b32 s43, s44, 10
	s_lshl_b32 s6, s35, 12
	s_lshl_b32 s23, s34, 11
	v_add_u32_e32 v131, s15, v4
	v_add_u32_e32 v130, s20, v4
	s_mov_b32 s0, s8
	s_add_i32 s41, s43, 0x2000
	s_add_i32 s9, s6, s23
	s_mov_b32 m0, s43
	s_add_i32 s42, s9, 0x4000
	s_mov_b32 s18, 0x900000
	s_add_i32 s40, s9, 0x4400
	s_and_b32 s13, s13, 0xffff
	s_waitcnt vmcnt(1)
	v_cndmask_b32_e32 v3, v9, v5, vcc
	v_cmp_gt_i32_e32 vcc, s25, v6
	v_mul_lo_u32 v3, v3, s14
	v_or_b32_e32 v134, v3, v8
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e32 v4, v9, v7, vcc
	v_mul_lo_u32 v3, v4, s14
	v_or_b32_e32 v133, v3, v8
	buffer_load_dwordx4 v134, s[0:3], 0 offen lds
	s_mov_b32 m0, s41
	v_lshlrev_b32_e32 v3, 2, v2
	buffer_load_dwordx4 v133, s[0:3], 0 offen lds
	s_mov_b32 m0, s42
	s_lshl_b32 s0, s21, 2
	buffer_load_dwordx4 v131, s[16:19], 0 offen lds
	s_mov_b32 m0, s40
	s_or_b32 s24, s0, s35
	buffer_load_dwordx4 v130, s[16:19], 0 offen lds
	s_mul_i32 s0, s24, 0x3000
	s_cmp_eq_u32 s34, 0
	s_mov_b32 s14, 0x90000
	s_cselect_b64 s[28:29], -1, 0
	s_cmp_lg_u32 s34, 0
	v_or_b32_e32 v132, s0, v3
	s_cbranch_scc1 .LBB0_3
	s_lshl_b32 s0, s44, 8
	s_add_i32 m0, s0, 0x8000
	s_mov_b32 s15, s3
	buffer_load_dword v132, s[12:15], 0 offen lds
.LBB0_3:
	s_or_b32 s45, s9, 0x400
	s_and_b32 s21, s11, 0xffff
	v_add_u32_e32 v4, s33, v3
	s_cmp_eq_u32 s44, 0
	s_mul_i32 s22, s7, 0xc0
	s_mov_b32 s23, 0x27000
	s_cselect_b64 s[30:31], -1, 0
	s_cmp_lg_u32 s44, 0
	v_lshl_add_u32 v135, v4, 2, s43
	s_cbranch_scc1 .LBB0_5
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], 0 offen lds
.LBB0_5:
	s_add_i32 s39, s41, 0x6800
	s_mov_b32 s0, s8
	s_mov_b32 m0, s39
	s_add_i32 s37, s41, 0x8800
	buffer_load_dwordx4 v134, s[0:3], 64 offen lds
	s_mov_b32 m0, s37
	s_add_i32 s36, s9, 0xc800
	buffer_load_dwordx4 v133, s[0:3], 64 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x400
	s_mov_b32 m0, s36
	s_add_i32 s38, s45, 0xc800
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_and_b64 s[46:47], s[28:29], exec
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_7
	s_lshl_b32 s0, s44, 8
	s_add_i32 m0, s0, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x100
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_7:
	s_and_b64 s[46:47], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_9
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s26 offen lds
.LBB0_9:
	s_cmp_lg_u32 s34, 1
	s_waitcnt vmcnt(4)
	s_barrier
	s_cbranch_scc1 .LBB0_11
	s_barrier
.LBB0_11:
	s_add_i32 s27, s41, 0xf000
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x80
	s_mov_b32 m0, s27
	s_add_i32 s11, s41, 0x11000
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_add_i32 s9, s9, 0x15000
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x800
	s_mov_b32 m0, s9
	s_add_i32 s26, s45, 0x15000
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_and_b64 s[46:47], s[28:29], exec
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_13
	s_lshl_b32 s0, s44, 8
	s_add_i32 m0, s0, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x200
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_13:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_15
	s_lshl_b32 s0, s7, 3
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_15:
	v_and_b32_e32 v128, 15, v0
	v_lshlrev_b32_e32 v4, 3, v0
	v_lshrrev_b32_e32 v129, 4, v2
	v_lshlrev_b32_e32 v2, 6, v128
	v_xor_b32_e32 v0, v4, v0
	v_and_or_b32 v0, v0, 48, v2
	v_lshl_or_b32 v136, s34, 13, v0
	v_lshlrev_b32_e32 v0, 2, v128
	s_lshl_b32 s0, s34, 9
	v_or3_b32 v0, s0, v0, v129
	ds_read_b128 v[14:17], v136
	ds_read_b128 v[30:33], v136 offset:1024
	ds_read_b128 v[46:49], v136 offset:2048
	ds_read_b128 v[62:65], v136 offset:3072
	ds_read_b128 v[78:81], v136 offset:4096
	ds_read_b128 v[94:97], v136 offset:5120
	ds_read_b128 v[110:113], v136 offset:6144
	ds_read_b128 v[140:143], v136 offset:7168
	ds_read_u8 v12, v0 offset:33792
	ds_read_u8 v28, v0 offset:33856
	ds_read_u8 v44, v0 offset:33920
	ds_read_u8 v60, v0 offset:33984
	ds_read_u8 v76, v0 offset:34048
	ds_read_u8 v92, v0 offset:34112
	ds_read_u8 v108, v0 offset:34176
	ds_read_u8 v124, v0 offset:34240
	v_or_b32_e32 v1, s6, v1
	ds_read_b128 v[114:117], v1 offset:16384
	ds_read_b128 v[118:121], v1 offset:17408
	ds_read_b128 v[144:147], v1 offset:18432
	ds_read_b128 v[148:151], v1 offset:19456
	s_lshl_b32 s35, s35, 8
	v_or_b32_e32 v2, s35, v3
	ds_read_b32 v125, v2 offset:32768
	v_add_u32_e32 v139, 0x8400, v0
	v_or_b32_e32 v138, 0x4000, v1
	v_or_b32_e32 v137, 0x8000, v2
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[14:17], v[114:117], 0, v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[14:17], v[118:121], 0, v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[14:17], v[144:147], 0, v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[14:17], v[148:151], 0, v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[30:33], v[114:117], 0, v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[30:33], v[118:121], 0, v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[30:33], v[144:147], 0, v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[30:33], v[148:151], 0, v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[46:49], v[114:117], 0, v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[46:49], v[118:121], 0, v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[46:49], v[144:147], 0, v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[46:49], v[148:151], 0, v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[62:65], v[114:117], 0, v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[62:65], v[118:121], 0, v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[62:65], v[144:147], 0, v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[62:65], v[148:151], 0, v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[78:81], v[114:117], 0, v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[78:81], v[118:121], 0, v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[78:81], v[144:147], 0, v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[78:81], v[148:151], 0, v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[94:97], v[114:117], 0, v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[94:97], v[118:121], 0, v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[94:97], v[144:147], 0, v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[94:97], v[148:151], 0, v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[110:113], v[114:117], 0, v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[110:113], v[118:121], 0, v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[110:113], v[144:147], 0, v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[110:113], v[148:151], 0, v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[140:143], v[114:117], 0, v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[140:143], v[118:121], 0, v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[140:143], v[144:147], 0, v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[140:143], v[148:151], 0, v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0xc0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0xc00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_17
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x300
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_17:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_19
	s_mul_i32 s0, s7, 12
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_19:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x100
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x1000
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_21
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x400
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_21:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_23
	s_lshl_b32 s0, s7, 4
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_23:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x140
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x1400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_25
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x500
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_25:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_27
	s_mul_i32 s0, s7, 20
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_27:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x180
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x1800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_29
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x600
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_29:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_31
	s_mul_i32 s0, s7, 24
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_31:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x1c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x1c00
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_33
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x700
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_33:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_35
	s_mul_i32 s0, s7, 28
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_35:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x200
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x2000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_37
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x800
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_37:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_39
	s_lshl_b32 s0, s7, 5
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_39:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x240
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x2400
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_41
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x900
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_41:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_43
	s_mul_i32 s0, s7, 36
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_43:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x280
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x2800
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_45
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xa00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_45:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_47
	s_mul_i32 s0, s7, 40
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_47:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x2c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x2c00
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_49
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xb00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_49:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_51
	s_mul_i32 s0, s7, 44
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_51:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s6, 0x300
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s6 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s6 offen lds
	s_movk_i32 s0, 0x3000
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_53
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xc00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_53:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_mul_i32 s6, s7, 48
	s_cbranch_scc1 .LBB0_55
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s6 offen lds
.LBB0_55:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x340
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x3400
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_57
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xd00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_57:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_59
	s_mul_i32 s0, s7, 52
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_59:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x380
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x3800
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_61
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xe00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_61:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_63
	s_mul_i32 s0, s7, 56
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_63:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x3c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x3c00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_65
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xf00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_65:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_67
	s_mul_i32 s0, s7, 60
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_67:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x400
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4000
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_69
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1000
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_69:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_71
	s_lshl_b32 s0, s7, 6
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_71:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x440
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_73
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1100
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_73:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_75
	s_mul_i32 s0, s7, 0x44
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_75:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x480
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_77
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1200
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_77:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_79
	s_mul_i32 s0, s7, 0x48
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_79:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x4c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4c00
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_81
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1300
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_81:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_83
	s_mul_i32 s0, s7, 0x4c
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_83:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x500
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x5000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_85
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1400
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_85:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_87
	s_mul_i32 s0, s7, 0x50
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_87:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x540
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x5400
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_89
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1500
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_89:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_91
	s_mul_i32 s0, s7, 0x54
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_91:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x580
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x5800
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_93
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1600
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_93:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_95
	s_mul_i32 s0, s7, 0x58
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_95:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x5c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x5c00
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_97
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1700
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_97:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_99
	s_mul_i32 s0, s7, 0x5c
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_99:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x600
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6000
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_101
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1800
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_101:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_103
	s_mul_i32 s0, s7, 0x60
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_103:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x640
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6400
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_105
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1900
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_105:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_107
	s_mul_i32 s0, s7, 0x64
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_107:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x680
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6800
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_109
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1a00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_109:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_111
	s_mul_i32 s0, s7, 0x68
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_111:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x6c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6c00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_113
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1b00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_113:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_115
	s_mul_i32 s0, s7, 0x6c
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_115:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x700
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7000
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_117
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1c00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_117:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_119
	s_mul_i32 s0, s7, 0x70
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_119:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x740
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_121
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1d00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_121:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_123
	s_mul_i32 s0, s7, 0x74
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_123:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x780
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_125
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1e00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_125:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_127
	s_mul_i32 s0, s7, 0x78
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_127:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x7c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7c00
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_129
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1f00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_129:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_131
	s_mul_i32 s0, s7, 0x7c
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_131:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x800
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x8000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_133
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2000
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_133:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_135
	s_lshl_b32 s0, s7, 7
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_135:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x840
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x8400
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_137
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2100
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_137:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_139
	s_mul_i32 s0, s7, 0x84
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_139:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x880
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x8800
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_141
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2200
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_141:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_143
	s_mul_i32 s0, s7, 0x88
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_143:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x8c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x8c00
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_145
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2300
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_145:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_147
	s_mul_i32 s0, s7, 0x8c
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_147:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x900
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9000
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_149
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2400
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_149:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_151
	s_mul_i32 s0, s7, 0x90
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_151:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x940
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9400
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_153
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2500
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_153:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_155
	s_mul_i32 s0, s7, 0x94
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_155:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x980
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9800
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_157
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2600
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_157:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_159
	s_mul_i32 s0, s7, 0x98
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_159:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x9c0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9c00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_161
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2700
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_161:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_163
	s_mul_i32 s0, s7, 0x9c
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_163:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xa00
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xa000
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_165
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2800
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_165:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_167
	s_mul_i32 s0, s7, 0xa0
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_167:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xa40
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xa400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_169
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2900
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_169:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_171
	s_mul_i32 s0, s7, 0xa4
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_171:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xa80
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xa800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_173
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2a00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_173:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_175
	s_mul_i32 s0, s7, 0xa8
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_175:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xac0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xac00
	s_mov_b32 m0, s36
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_177
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2b00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_177:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_179
	s_mul_i32 s0, s7, 0xac
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_179:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xb00
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xb000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_181
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2c00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_181:
	s_and_b64 s[44:45], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_183
	s_mul_i32 s0, s7, 0xb0
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_183:
	ds_read_b128 v[150:153], v136
	ds_read_b128 v[154:157], v136 offset:1024
	ds_read_b128 v[158:161], v136 offset:2048
	ds_read_b128 v[162:165], v136 offset:3072
	ds_read_b128 v[166:169], v136 offset:4096
	ds_read_b128 v[170:173], v136 offset:5120
	ds_read_b128 v[174:177], v136 offset:6144
	ds_read_b128 v[178:181], v136 offset:7168
	ds_read_u8 v140, v139
	ds_read_u8 v141, v139 offset:64
	ds_read_u8 v142, v139 offset:128
	ds_read_u8 v143, v139 offset:192
	ds_read_u8 v144, v139 offset:256
	ds_read_u8 v145, v139 offset:320
	ds_read_u8 v146, v139 offset:384
	ds_read_u8 v147, v139 offset:448
	ds_read_b128 v[182:185], v138
	ds_read_b128 v[186:189], v138 offset:1024
	ds_read_b128 v[190:193], v138 offset:2048
	ds_read_b128 v[194:197], v138 offset:3072
	ds_read_b32 v148, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xb40
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xb400
	s_mov_b32 m0, s42
	s_nop 0
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_and_b64 s[40:41], s[28:29], exec
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_185
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2d00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_185:
	s_and_b64 s[40:41], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_187
	s_mul_i32 s0, s7, 0xb4
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x8400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_187:
	ds_read_b128 v[150:153], v136 offset:34816
	ds_read_b128 v[154:157], v136 offset:35840
	ds_read_b128 v[158:161], v136 offset:36864
	ds_read_b128 v[162:165], v136 offset:37888
	ds_read_b128 v[166:169], v136 offset:38912
	ds_read_b128 v[170:173], v136 offset:39936
	ds_read_b128 v[174:177], v136 offset:40960
	ds_read_b128 v[178:181], v136 offset:41984
	ds_read_u8 v140, v139 offset:34816
	ds_read_u8 v141, v139 offset:34880
	ds_read_u8 v142, v139 offset:34944
	ds_read_u8 v143, v139 offset:35008
	ds_read_u8 v144, v139 offset:35072
	ds_read_u8 v145, v139 offset:35136
	ds_read_u8 v146, v139 offset:35200
	ds_read_u8 v147, v139 offset:35264
	ds_read_b128 v[182:185], v138 offset:34816
	ds_read_b128 v[186:189], v138 offset:35840
	ds_read_b128 v[190:193], v138 offset:36864
	ds_read_b128 v[194:197], v138 offset:37888
	ds_read_b32 v148, v137 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xb80
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xb800
	s_mov_b32 m0, s36
	s_and_b64 s[36:37], s[28:29], exec
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_189
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2e00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_189:
	s_and_b64 s[36:37], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_191
	s_mul_i32 s0, s7, 0xb8
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x10c00
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_191:
	v_add_u32_e32 v140, 0x11000, v136
	ds_read_b128 v[150:153], v140
	v_add_u32_e32 v140, 0x11400, v136
	ds_read_b128 v[154:157], v140
	v_add_u32_e32 v140, 0x11800, v136
	ds_read_b128 v[158:161], v140
	v_add_u32_e32 v140, 0x11c00, v136
	ds_read_b128 v[162:165], v140
	v_add_u32_e32 v140, 0x12000, v136
	v_add_u32_e32 v148, 0x11000, v138
	ds_read_b128 v[166:169], v140
	v_add_u32_e32 v140, 0x12400, v136
	ds_read_b128 v[182:185], v148
	v_add_u32_e32 v148, 0x11400, v138
	ds_read_b128 v[170:173], v140
	v_add_u32_e32 v140, 0x12800, v136
	ds_read_b128 v[186:189], v148
	v_add_u32_e32 v148, 0x11800, v138
	ds_read_b128 v[174:177], v140
	v_add_u32_e32 v140, 0x12c00, v136
	ds_read_b128 v[190:193], v148
	v_add_u32_e32 v148, 0x11c00, v138
	ds_read_b128 v[178:181], v140
	v_add_u32_e32 v140, 0x11000, v139
	v_add_u32_e32 v141, 0x11040, v139
	v_add_u32_e32 v142, 0x11080, v139
	v_add_u32_e32 v143, 0x110c0, v139
	v_add_u32_e32 v144, 0x11100, v139
	v_add_u32_e32 v145, 0x11140, v139
	v_add_u32_e32 v146, 0x11180, v139
	v_add_u32_e32 v147, 0x111c0, v139
	ds_read_b128 v[194:197], v148
	v_add_u32_e32 v148, 0x11000, v137
	ds_read_u8 v140, v140
	ds_read_u8 v141, v141
	ds_read_u8 v142, v142
	ds_read_u8 v143, v143
	ds_read_u8 v144, v144
	ds_read_u8 v145, v145
	ds_read_u8 v146, v146
	ds_read_u8 v147, v147
	ds_read_b32 v148, v148
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[150:153], v[182:185], v[0:3], v140, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[150:153], v[186:189], v[4:7], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[150:153], v[190:193], v[8:11], v140, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[150:153], v[194:197], v[12:15], v140, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[154:157], v[182:185], v[16:19], v141, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[154:157], v[186:189], v[20:23], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[154:157], v[190:193], v[24:27], v141, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[154:157], v[194:197], v[28:31], v141, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[158:161], v[182:185], v[32:35], v142, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[158:161], v[186:189], v[36:39], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[158:161], v[190:193], v[40:43], v142, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[158:161], v[194:197], v[44:47], v142, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[162:165], v[182:185], v[48:51], v143, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[162:165], v[186:189], v[52:55], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[162:165], v[190:193], v[56:59], v143, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[162:165], v[194:197], v[60:63], v143, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[166:169], v[182:185], v[64:67], v144, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[166:169], v[186:189], v[68:71], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[166:169], v[190:193], v[72:75], v144, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[166:169], v[194:197], v[76:79], v144, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[170:173], v[182:185], v[80:83], v145, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[170:173], v[186:189], v[84:87], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[170:173], v[190:193], v[88:91], v145, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[170:173], v[194:197], v[92:95], v145, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[174:177], v[182:185], v[96:99], v146, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[174:177], v[186:189], v[100:103], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[174:177], v[190:193], v[104:107], v146, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[174:177], v[194:197], v[108:111], v146, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[178:181], v[182:185], v[112:115], v147, v148 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[178:181], v[186:189], v[116:119], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[178:181], v[190:193], v[120:123], v147, v148 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[178:181], v[194:197], v[124:127], v147, v148 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s27
	s_mov_b32 s0, s8
	s_movk_i32 s8, 0xbc0
	s_barrier
	buffer_load_dwordx4 v134, s[0:3], s8 offen lds
	s_mov_b32 m0, s11
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v133, s[0:3], s8 offen lds
	s_mov_b32 s0, 0xbc00
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v131, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v130, s[16:19], s0 offen lds
	s_and_b64 s[0:1], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_193
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2f00
	buffer_load_dword v132, s[12:15], s0 offen lds
.LBB0_193:
	s_and_b64 s[0:1], s[30:31], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_195
	s_mul_i32 s0, s7, 0xbc
	s_mov_b32 s20, s10
	s_mov_b32 m0, 0x19400
	s_nop 0
	buffer_load_dwordx4 v135, s[20:23], s0 offen lds
.LBB0_195:
	ds_read_b128 v[144:147], v136
	ds_read_b128 v[148:151], v136 offset:1024
	ds_read_b128 v[152:155], v136 offset:2048
	ds_read_b128 v[156:159], v136 offset:3072
	ds_read_b128 v[160:163], v136 offset:4096
	ds_read_b128 v[164:167], v136 offset:5120
	ds_read_b128 v[168:171], v136 offset:6144
	ds_read_b128 v[172:175], v136 offset:7168
	ds_read_u8 v130, v139
	ds_read_u8 v131, v139 offset:64
	ds_read_u8 v132, v139 offset:128
	ds_read_u8 v133, v139 offset:192
	ds_read_u8 v134, v139 offset:256
	ds_read_u8 v135, v139 offset:320
	ds_read_u8 v140, v139 offset:384
	ds_read_u8 v141, v139 offset:448
	ds_read_b128 v[176:179], v138
	ds_read_b128 v[180:183], v138 offset:1024
	ds_read_b128 v[184:187], v138 offset:2048
	ds_read_b128 v[188:191], v138 offset:3072
	ds_read_b32 v142, v137
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[144:147], v[176:179], v[0:3], v130, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[144:147], v[180:183], v[4:7], v130, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[144:147], v[184:187], v[8:11], v130, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[144:147], v[188:191], v[12:15], v130, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[148:151], v[176:179], v[16:19], v131, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[148:151], v[180:183], v[20:23], v131, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[148:151], v[184:187], v[24:27], v131, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[148:151], v[188:191], v[28:31], v131, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[152:155], v[176:179], v[32:35], v132, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[152:155], v[180:183], v[36:39], v132, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[152:155], v[184:187], v[40:43], v132, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[152:155], v[188:191], v[44:47], v132, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[156:159], v[176:179], v[48:51], v133, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[156:159], v[180:183], v[52:55], v133, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[156:159], v[184:187], v[56:59], v133, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[156:159], v[188:191], v[60:63], v133, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[160:163], v[176:179], v[64:67], v134, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[160:163], v[180:183], v[68:71], v134, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[160:163], v[184:187], v[72:75], v134, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[160:163], v[188:191], v[76:79], v134, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[164:167], v[176:179], v[80:83], v135, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[164:167], v[180:183], v[84:87], v135, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[164:167], v[184:187], v[88:91], v135, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[164:167], v[188:191], v[92:95], v135, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[168:171], v[176:179], v[96:99], v140, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[168:171], v[180:183], v[100:103], v140, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[168:171], v[184:187], v[104:107], v140, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[168:171], v[188:191], v[108:111], v140, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[172:175], v[176:179], v[112:115], v141, v142 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[172:175], v[180:183], v[116:119], v141, v142 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[172:175], v[184:187], v[120:123], v141, v142 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[172:175], v[188:191], v[124:127], v141, v142 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_barrier
	ds_read_b128 v[140:143], v136 offset:34816
	ds_read_b128 v[144:147], v136 offset:35840
	ds_read_b128 v[148:151], v136 offset:36864
	ds_read_b128 v[152:155], v136 offset:37888
	ds_read_b128 v[156:159], v136 offset:38912
	ds_read_b128 v[164:167], v136 offset:39936
	ds_read_b128 v[182:185], v136 offset:40960
	ds_read_b128 v[198:201], v136 offset:41984
	ds_read_u8 v130, v139 offset:34816
	ds_read_u8 v131, v139 offset:34880
	ds_read_u8 v132, v139 offset:34944
	ds_read_u8 v133, v139 offset:35008
	ds_read_u8 v134, v139 offset:35072
	ds_read_u8 v135, v139 offset:35136
	ds_read_u8 v180, v139 offset:35200
	ds_read_u8 v196, v139 offset:35264
	ds_read_b128 v[186:189], v138 offset:34816
	ds_read_b128 v[190:193], v138 offset:35840
	ds_read_b128 v[202:205], v138 offset:36864
	ds_read_b128 v[206:209], v138 offset:37888
	ds_read_b32 v197, v137 offset:34816
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[140:143], v[186:189], v[0:3], v130, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[140:143], v[190:193], v[4:7], v130, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[140:143], v[202:205], v[8:11], v130, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[140:143], v[206:209], v[12:15], v130, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[144:147], v[186:189], v[16:19], v131, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[144:147], v[190:193], v[20:23], v131, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[144:147], v[202:205], v[24:27], v131, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[144:147], v[206:209], v[28:31], v131, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[148:151], v[186:189], v[32:35], v132, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[148:151], v[190:193], v[36:39], v132, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[148:151], v[202:205], v[40:43], v132, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[148:151], v[206:209], v[44:47], v132, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[152:155], v[186:189], v[48:51], v133, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[152:155], v[190:193], v[52:55], v133, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[152:155], v[202:205], v[56:59], v133, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[152:155], v[206:209], v[60:63], v133, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[130:133], v[156:159], v[186:189], v[64:67], v134, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[140:143], v[156:159], v[190:193], v[68:71], v134, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[144:147], v[156:159], v[202:205], v[72:75], v134, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[148:151], v[156:159], v[206:209], v[76:79], v134, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[152:155], v[164:167], v[186:189], v[80:83], v135, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[156:159], v[164:167], v[190:193], v[84:87], v135, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[160:163], v[164:167], v[202:205], v[88:91], v135, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[164:167], v[164:167], v[206:209], v[92:95], v135, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[168:171], v[182:185], v[186:189], v[96:99], v180, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[172:175], v[182:185], v[190:193], v[100:103], v180, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[176:179], v[182:185], v[202:205], v[104:107], v180, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[180:183], v[182:185], v[206:209], v[108:111], v180, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[184:187], v[198:201], v[186:189], v[112:115], v196, v197 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[188:191], v[198:201], v[190:193], v[116:119], v196, v197 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[192:195], v[198:201], v[202:205], v[120:123], v196, v197 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[196:199], v[198:201], v[206:209], v[124:127], v196, v197 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	v_add_u32_e32 v64, 0x11000, v136
	s_barrier
	ds_read_b128 v[70:73], v64
	v_add_u32_e32 v64, 0x11400, v136
	ds_read_b128 v[74:77], v64
	v_add_u32_e32 v64, 0x11800, v136
	ds_read_b128 v[78:81], v64
	v_add_u32_e32 v64, 0x11c00, v136
	ds_read_b128 v[200:203], v64
	v_add_u32_e32 v64, 0x12000, v136
	v_add_u32_e32 v68, 0x11100, v139
	ds_read_b128 v[204:207], v64
	v_add_u32_e32 v64, 0x12400, v136
	ds_read_u8 v134, v68
	v_add_u32_e32 v68, 0x11140, v139
	ds_read_b128 v[208:211], v64
	v_add_u32_e32 v64, 0x12800, v136
	ds_read_u8 v135, v68
	v_add_u32_e32 v68, 0x11180, v139
	ds_read_b128 v[212:215], v64
	v_add_u32_e32 v64, 0x12c00, v136
	ds_read_u8 v136, v68
	v_add_u32_e32 v68, 0x111c0, v139
	ds_read_b128 v[216:219], v64
	v_add_u32_e32 v64, 0x11000, v139
	v_add_u32_e32 v65, 0x11040, v139
	v_add_u32_e32 v66, 0x11080, v139
	v_add_u32_e32 v67, 0x110c0, v139
	ds_read_u8 v139, v68
	v_add_u32_e32 v68, 0x11000, v138
	ds_read_b128 v[220:223], v68
	v_add_u32_e32 v68, 0x11400, v138
	ds_read_b128 v[224:227], v68
	v_add_u32_e32 v68, 0x11800, v138
	ds_read_b128 v[228:231], v68
	v_add_u32_e32 v68, 0x11c00, v138
	ds_read_u8 v64, v64
	ds_read_u8 v65, v65
	ds_read_u8 v66, v66
	ds_read_u8 v67, v67
	ds_read_b128 v[232:235], v68
	v_add_u32_e32 v68, 0x11000, v137
	ds_read_b32 v137, v68
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], v[70:73], v[220:223], v[0:3], v64, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[116:119], v[70:73], v[224:227], v[4:7], v64, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[120:123], v[70:73], v[228:231], v[8:11], v64, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[112:115], v[70:73], v[232:235], v[12:15], v64, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], v[74:77], v[220:223], v[16:19], v65, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[100:103], v[74:77], v[224:227], v[20:23], v65, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[74:77], v[228:231], v[24:27], v65, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[96:99], v[74:77], v[232:235], v[28:31], v65, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], v[78:81], v[220:223], v[32:35], v66, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[78:81], v[224:227], v[36:39], v66, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[78:81], v[228:231], v[40:43], v66, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[78:81], v[232:235], v[44:47], v66, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], v[200:203], v[220:223], v[48:51], v67, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[200:203], v[224:227], v[52:55], v67, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[200:203], v[228:231], v[56:59], v67, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[200:203], v[232:235], v[60:63], v67, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], v[204:207], v[220:223], v[130:133], v134, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[204:207], v[224:227], v[140:143], v134, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[204:207], v[228:231], v[144:147], v134, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[204:207], v[232:235], v[148:151], v134, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], v[208:211], v[220:223], v[152:155], v135, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[208:211], v[224:227], v[156:159], v135, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[208:211], v[228:231], v[160:163], v135, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[208:211], v[232:235], v[164:167], v135, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[212:215], v[220:223], v[168:171], v136, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[212:215], v[224:227], v[172:175], v136, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[212:215], v[228:231], v[176:179], v136, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], v[212:215], v[232:235], v[180:183], v136, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[12:15], v[216:219], v[220:223], v[184:187], v139, v137 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], v[216:219], v[224:227], v[188:191], v139, v137 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[8:11], v[216:219], v[228:231], v[192:195], v139, v137 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], v[216:219], v[232:235], v[196:199], v139, v137 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_and_b64 s[0:1], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_barrier
	s_cbranch_scc1 .LBB0_197
	s_barrier
.LBB0_197:
	s_load_dwordx4 s[0:3], s[4:5], 0x40
	v_lshlrev_b32_e32 v129, 2, v129
	v_lshl_or_b32 v130, s34, 7, v129
	s_movk_i32 s13, 0x300
	v_add_u32_e32 v131, s33, v130
	v_mul_lo_u32 v129, v131, s13
	s_lshl_b32 s15, s24, 4
	v_add_u32_e32 v129, s15, v129
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s1, 0xffff
	s_mov_b32 s8, s0
	v_or_b32_e32 v132, v129, v128
	v_mov_b32_e32 v129, 0x7ffffff0
	v_cmp_gt_i32_e64 s[0:1], s25, v130
	v_cmp_eq_u32_e32 vcc, 0, v128
	s_and_b32 s5, s3, 0xffff
	s_mov_b32 s4, s2
	v_cndmask_b32_e64 v140, v129, v132, s[0:1]
	v_mad_u64_u32 v[132:133], s[2:3], v131, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_mov_b32 s17, 0x40e00000
	v_cndmask_b32_e64 v131, v129, v132, s[0:1]
	v_minimum3_f32 v124, v124, s17, s17
	v_minimum3_f32 v132, v116, s17, s17
	v_minimum3_f32 v133, v117, s17, s17
	v_mov_b32_e32 v116, v124
	v_mov_b32_e32 v117, v132
	s_mov_b32 s12, 0xc01d265f
	v_pk_mul_f32 v[134:135], v[116:117], s[12:13] op_sel_hi:[1,0]
	s_mov_b32 s18, 0xc2fc0000
	v_mov_b32_e32 v116, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s18, v135
	v_cmp_gt_f32_e64 s[2:3], s18, v134
	v_minimum3_f32 v125, v125, s17, s17
	v_cndmask_b32_e64 v117, 0, v116, s[0:1]
	v_add_f32_e32 v117, v135, v117
	v_cndmask_b32_e64 v136, 0, v116, s[2:3]
	v_exp_f32_e32 v135, v117
	v_add_f32_e32 v134, v134, v136
	v_exp_f32_e32 v134, v134
	v_not_b32_e32 v117, 63
	v_cndmask_b32_e64 v136, 0, v117, s[0:1]
	v_ldexp_f32 v135, v135, v136
	v_cndmask_b32_e64 v136, 0, v117, s[2:3]
	v_minimum3_f32 v138, v112, s17, s17
	v_minimum3_f32 v137, v113, s17, s17
	v_mov_b32_e32 v112, v125
	v_mov_b32_e32 v113, v133
	v_ldexp_f32 v134, v134, v136
	v_pk_mul_f32 v[112:113], v[112:113], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[134:135], v[134:135], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v113
	v_rcp_f32_e32 v136, v135
	v_cmp_gt_f32_e64 s[2:3], s18, v112
	v_cndmask_b32_e64 v135, 0, v116, s[0:1]
	v_add_f32_e32 v113, v113, v135
	v_cndmask_b32_e64 v135, 0, v116, s[2:3]
	v_exp_f32_e32 v113, v113
	v_add_f32_e32 v112, v112, v135
	v_exp_f32_e32 v112, v112
	v_cndmask_b32_e64 v135, 0, v117, s[0:1]
	v_ldexp_f32 v113, v113, v135
	v_cndmask_b32_e64 v135, 0, v117, s[2:3]
	v_ldexp_f32 v112, v112, v135
	v_pk_add_f32 v[112:113], v[112:113], 1.0 op_sel_hi:[1,0]
	s_mov_b32 s16, 0xc0e00000
	v_rcp_f32_e32 v134, v134
	v_rcp_f32_e32 v135, v112
	v_maximum3_f32 v139, v137, s16, s16
	v_rcp_f32_e32 v137, v113
	v_minimum3_f32 v120, v120, s17, s17
	v_minimum3_f32 v121, v121, s17, s17
	v_maximum3_f32 v121, v121, s16, s16
	v_maximum3_f32 v120, v120, s16, s16
	v_pk_add_f32 v[120:121], v[120:121], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v138, v138, s16, s16
	v_pk_mul_f32 v[112:113], v[124:125], v[134:135]
	v_pk_add_f32 v[124:125], v[138:139], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[120:121], v[120:121], v[112:113]
	v_pk_mul_f32 v[112:113], v[132:133], v[136:137]
	s_mov_b32 s14, 0x3e2aaaab
	v_pk_mul_f32 v[124:125], v[124:125], v[112:113]
	s_movk_i32 s19, 0xfe
	v_maximum3_f32 v112, |v121|, |v125|, |v125|
	v_maximum3_f32 v113, |v120|, |v124|, |v124|
	v_mov_b32_e32 v135, 0
	v_max_u32_dpp v112, v112, v112 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v113, v113, v113 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v141, 1, v130
	v_max_u32_dpp v112, v112, v112 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v113, v113, v113 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cmp_gt_i32_e64 s[0:1], s25, v141
	v_max_u32_dpp v112, v112, v112 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v132, v113, v113 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_mul_i32 s10, s7, 0x300
	v_max_u32_dpp v113, v112, v112 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v112, v132, v132 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[112:113], v[112:113], s[14:15] op_sel_hi:[1,0]
	s_mov_b32 s11, 0x27000
	v_add_u32_e32 v112, 0x7fffff, v112
	v_add_u32_e32 v113, 0x7fffff, v113
	v_lshrrev_b32_e32 v112, 23, v112
	v_lshrrev_b32_e32 v113, 23, v113
	v_min_u32_sdwa v132, v112, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v113, v113, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v134, 23, v132
	v_lshlrev_b32_e32 v133, 23, v113
	v_cvt_scalef32_pk_fp4_f32 v135, v120, v124, v134
	v_mov_b32_e32 v120, 0
	v_cvt_scalef32_pk_fp4_f32 v120, v121, v125, v133
	v_add_u32_e32 v121, s33, v141
	v_mul_lo_u32 v124, v121, s13
	v_add_u32_e32 v124, s15, v124
	v_or_b32_e32 v124, v124, v128
	v_cndmask_b32_e64 v124, v129, v124, s[0:1]
	s_mov_b32 s7, s11
	buffer_store_byte v135, v140, s[8:11], 0 offen
	buffer_store_byte v132, v131, s[4:7], 0 offen
	buffer_store_byte v120, v124, s[8:11], 0 offen
	v_mad_u64_u32 v[120:121], s[2:3], v121, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v120, v129, v120, s[0:1]
	buffer_store_byte v113, v120, s[4:7], 0 offen
	v_or_b32_e32 v113, 2, v130
	v_add_u32_e32 v120, s33, v113
	v_mul_lo_u32 v121, v120, s13
	v_add_u32_e32 v121, s15, v121
	v_or_b32_e32 v121, v121, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v113
	v_minimum3_f32 v118, v118, s17, s17
	v_mov_b32_e32 v125, v118
	v_cndmask_b32_e64 v113, v129, v121, s[0:1]
	v_mad_u64_u32 v[120:121], s[2:3], v120, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v131, v129, v120, s[0:1]
	v_minimum3_f32 v120, v126, s17, s17
	v_mov_b32_e32 v124, v120
	v_pk_mul_f32 v[124:125], v[124:125], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v121, v127, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v125
	v_cmp_gt_f32_e64 s[2:3], s18, v124
	v_minimum3_f32 v119, v119, s17, s17
	v_cndmask_b32_e64 v126, 0, v116, s[0:1]
	v_add_f32_e32 v125, v125, v126
	v_cndmask_b32_e64 v126, 0, v116, s[2:3]
	v_exp_f32_e32 v125, v125
	v_add_f32_e32 v124, v124, v126
	v_exp_f32_e32 v124, v124
	v_cndmask_b32_e64 v126, 0, v117, s[0:1]
	v_ldexp_f32 v125, v125, v126
	v_cndmask_b32_e64 v126, 0, v117, s[2:3]
	v_minimum3_f32 v132, v114, s17, s17
	v_minimum3_f32 v127, v115, s17, s17
	v_mov_b32_e32 v114, v121
	v_mov_b32_e32 v115, v119
	v_ldexp_f32 v124, v124, v126
	v_pk_mul_f32 v[114:115], v[114:115], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[124:125], v[124:125], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v115
	v_rcp_f32_e32 v126, v125
	v_cmp_gt_f32_e64 s[2:3], s18, v114
	v_cndmask_b32_e64 v125, 0, v116, s[0:1]
	v_add_f32_e32 v115, v115, v125
	v_cndmask_b32_e64 v125, 0, v116, s[2:3]
	v_exp_f32_e32 v115, v115
	v_add_f32_e32 v114, v114, v125
	v_exp_f32_e32 v114, v114
	v_cndmask_b32_e64 v125, 0, v117, s[0:1]
	v_ldexp_f32 v115, v115, v125
	v_cndmask_b32_e64 v125, 0, v117, s[2:3]
	v_ldexp_f32 v114, v114, v125
	v_pk_add_f32 v[114:115], v[114:115], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v124, v124
	v_rcp_f32_e32 v125, v114
	v_maximum3_f32 v133, v127, s16, s16
	v_rcp_f32_e32 v127, v115
	v_minimum3_f32 v122, v122, s17, s17
	v_minimum3_f32 v123, v123, s17, s17
	v_maximum3_f32 v123, v123, s16, s16
	v_maximum3_f32 v122, v122, s16, s16
	v_maximum3_f32 v132, v132, s16, s16
	v_pk_add_f32 v[122:123], v[122:123], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[114:115], v[120:121], v[124:125]
	v_pk_mul_f32 v[118:119], v[118:119], v[126:127]
	v_pk_add_f32 v[120:121], v[132:133], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[114:115], v[122:123], v[114:115]
	v_pk_mul_f32 v[118:119], v[120:121], v[118:119]
	v_mov_b32_e32 v124, 0
	v_maximum3_f32 v120, |v115|, |v119|, |v119|
	v_maximum3_f32 v121, |v114|, |v118|, |v118|
	v_or_b32_e32 v134, 3, v130
	v_max_u32_dpp v120, v120, v120 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v121, v121, v121 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cmp_gt_i32_e64 s[0:1], s25, v134
	v_max_u32_dpp v120, v120, v120 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v121, v121, v121 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v108, v108, s17, s17
	v_max_u32_dpp v120, v120, v120 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v122, v121, v121 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v100, v100, s17, s17
	v_max_u32_dpp v121, v120, v120 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v120, v122, v122 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[120:121], v[120:121], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v109, v109, s17, s17
	v_add_u32_e32 v120, 0x7fffff, v120
	v_lshrrev_b32_e32 v120, 23, v120
	v_add_u32_e32 v121, 0x7fffff, v121
	v_min_u32_sdwa v120, v120, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshrrev_b32_e32 v121, 23, v121
	v_lshlrev_b32_e32 v123, 23, v120
	v_min_u32_sdwa v121, v121, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_cvt_scalef32_pk_fp4_f32 v124, v114, v118, v123
	v_lshlrev_b32_e32 v122, 23, v121
	buffer_store_byte v124, v113, s[8:11], 0 offen
	buffer_store_byte v120, v131, s[4:7], 0 offen
	v_mov_b32_e32 v113, 0
	v_add_u32_e32 v114, s33, v134
	v_cvt_scalef32_pk_fp4_f32 v113, v115, v119, v122
	v_mul_lo_u32 v115, v114, s13
	v_add_u32_e32 v115, s15, v115
	v_or_b32_e32 v115, v115, v128
	v_cndmask_b32_e64 v115, v129, v115, s[0:1]
	buffer_store_byte v113, v115, s[8:11], 0 offen
	v_mad_u64_u32 v[114:115], s[2:3], v114, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v113, v129, v114, s[0:1]
	buffer_store_byte v121, v113, s[4:7], 0 offen
	v_or_b32_e32 v113, 16, v130
	v_add_u32_e32 v114, s33, v113
	v_mul_lo_u32 v115, v114, s13
	v_add_u32_e32 v115, s15, v115
	v_or_b32_e32 v115, v115, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v113
	v_minimum3_f32 v101, v101, s17, s17
	v_minimum3_f32 v120, v96, s17, s17
	v_cndmask_b32_e64 v113, v129, v115, s[0:1]
	v_mad_u64_u32 v[114:115], s[2:3], v114, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v122, v129, v114, s[0:1]
	v_mov_b32_e32 v114, v108
	v_mov_b32_e32 v115, v100
	v_pk_mul_f32 v[114:115], v[114:115], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v119, v97, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v115
	v_cmp_gt_f32_e64 s[2:3], s18, v114
	v_mov_b32_e32 v96, v109
	v_cndmask_b32_e64 v118, 0, v116, s[0:1]
	v_add_f32_e32 v115, v115, v118
	v_cndmask_b32_e64 v118, 0, v116, s[2:3]
	v_exp_f32_e32 v115, v115
	v_add_f32_e32 v114, v114, v118
	v_exp_f32_e32 v114, v114
	v_cndmask_b32_e64 v118, 0, v117, s[0:1]
	v_ldexp_f32 v115, v115, v118
	v_cndmask_b32_e64 v118, 0, v117, s[2:3]
	v_mov_b32_e32 v97, v101
	v_ldexp_f32 v114, v114, v118
	v_pk_mul_f32 v[96:97], v[96:97], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[114:115], v[114:115], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v97
	v_rcp_f32_e32 v118, v115
	v_cmp_gt_f32_e64 s[2:3], s18, v96
	v_cndmask_b32_e64 v115, 0, v116, s[0:1]
	v_add_f32_e32 v97, v97, v115
	v_cndmask_b32_e64 v115, 0, v116, s[2:3]
	v_exp_f32_e32 v97, v97
	v_add_f32_e32 v96, v96, v115
	v_exp_f32_e32 v96, v96
	v_cndmask_b32_e64 v115, 0, v117, s[0:1]
	v_ldexp_f32 v97, v97, v115
	v_cndmask_b32_e64 v115, 0, v117, s[2:3]
	v_ldexp_f32 v96, v96, v115
	v_pk_add_f32 v[96:97], v[96:97], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v114, v114
	v_rcp_f32_e32 v115, v96
	v_maximum3_f32 v121, v119, s16, s16
	v_rcp_f32_e32 v119, v97
	v_minimum3_f32 v104, v104, s17, s17
	v_minimum3_f32 v105, v105, s17, s17
	v_maximum3_f32 v105, v105, s16, s16
	v_maximum3_f32 v104, v104, s16, s16
	v_pk_add_f32 v[104:105], v[104:105], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v120, v120, s16, s16
	v_pk_mul_f32 v[96:97], v[108:109], v[114:115]
	v_pk_mul_f32 v[100:101], v[100:101], v[118:119]
	v_pk_mul_f32 v[96:97], v[104:105], v[96:97]
	v_pk_add_f32 v[104:105], v[120:121], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v114, 0
	v_pk_mul_f32 v[100:101], v[104:105], v[100:101]
	v_or_b32_e32 v123, 17, v130
	v_maximum3_f32 v104, |v97|, |v101|, |v101|
	v_maximum3_f32 v105, |v96|, |v100|, |v100|
	v_cmp_gt_i32_e64 s[0:1], s25, v123
	v_max_u32_dpp v104, v104, v104 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v105, v105, v105 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v102, v102, s17, s17
	v_max_u32_dpp v104, v104, v104 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v105, v105, v105 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v103, v103, s17, s17
	v_max_u32_dpp v104, v104, v104 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v108, v105, v105 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v115, 19, v130
	v_max_u32_dpp v105, v104, v104 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v104, v108, v108 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[104:105], v[104:105], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v92, v92, s17, s17
	v_add_u32_e32 v104, 0x7fffff, v104
	v_add_u32_e32 v105, 0x7fffff, v105
	v_lshrrev_b32_e32 v104, 23, v104
	v_lshrrev_b32_e32 v105, 23, v105
	v_min_u32_sdwa v104, v104, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v105, v105, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v109, 23, v104
	v_lshlrev_b32_e32 v108, 23, v105
	v_cvt_scalef32_pk_fp4_f32 v114, v96, v100, v109
	v_mov_b32_e32 v96, 0
	v_cvt_scalef32_pk_fp4_f32 v96, v97, v101, v108
	v_add_u32_e32 v97, s33, v123
	v_mul_lo_u32 v100, v97, s13
	v_add_u32_e32 v100, s15, v100
	v_or_b32_e32 v100, v100, v128
	v_cndmask_b32_e64 v100, v129, v100, s[0:1]
	buffer_store_byte v114, v113, s[8:11], 0 offen
	buffer_store_byte v104, v122, s[4:7], 0 offen
	buffer_store_byte v96, v100, s[8:11], 0 offen
	v_mad_u64_u32 v[96:97], s[2:3], v97, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v96, v129, v96, s[0:1]
	buffer_store_byte v105, v96, s[4:7], 0 offen
	v_or_b32_e32 v96, 18, v130
	v_add_u32_e32 v97, s33, v96
	v_mul_lo_u32 v100, v97, s13
	v_add_u32_e32 v100, s15, v100
	v_or_b32_e32 v100, v100, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v96
	v_mad_u64_u32 v[96:97], s[2:3], v97, 48, s[24:25]
	v_mov_b32_e32 v105, v102
	v_cndmask_b32_e64 v113, v129, v100, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v114, v129, v96, s[0:1]
	v_minimum3_f32 v96, v110, s17, s17
	v_mov_b32_e32 v104, v96
	v_pk_mul_f32 v[104:105], v[104:105], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v100, v106, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v105
	v_cmp_gt_f32_e64 s[2:3], s18, v104
	v_minimum3_f32 v97, v111, s17, s17
	v_cndmask_b32_e64 v106, 0, v116, s[0:1]
	v_add_f32_e32 v105, v105, v106
	v_cndmask_b32_e64 v106, 0, v116, s[2:3]
	v_exp_f32_e32 v105, v105
	v_add_f32_e32 v104, v104, v106
	v_exp_f32_e32 v104, v104
	v_cndmask_b32_e64 v106, 0, v117, s[0:1]
	v_minimum3_f32 v101, v107, s17, s17
	v_ldexp_f32 v105, v105, v106
	v_cndmask_b32_e64 v106, 0, v117, s[2:3]
	v_minimum3_f32 v108, v98, s17, s17
	v_minimum3_f32 v107, v99, s17, s17
	v_mov_b32_e32 v98, v97
	v_mov_b32_e32 v99, v103
	v_ldexp_f32 v104, v104, v106
	v_pk_mul_f32 v[98:99], v[98:99], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[104:105], v[104:105], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v99
	v_rcp_f32_e32 v106, v105
	v_cmp_gt_f32_e64 s[2:3], s18, v98
	v_cndmask_b32_e64 v105, 0, v116, s[0:1]
	v_add_f32_e32 v99, v99, v105
	v_cndmask_b32_e64 v105, 0, v116, s[2:3]
	v_exp_f32_e32 v99, v99
	v_add_f32_e32 v98, v98, v105
	v_exp_f32_e32 v98, v98
	v_cndmask_b32_e64 v105, 0, v117, s[0:1]
	v_ldexp_f32 v99, v99, v105
	v_cndmask_b32_e64 v105, 0, v117, s[2:3]
	v_ldexp_f32 v98, v98, v105
	v_pk_add_f32 v[98:99], v[98:99], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v104, v104
	v_rcp_f32_e32 v105, v98
	v_maximum3_f32 v109, v107, s16, s16
	v_rcp_f32_e32 v107, v99
	v_maximum3_f32 v101, v101, s16, s16
	v_maximum3_f32 v100, v100, s16, s16
	v_pk_add_f32 v[100:101], v[100:101], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v108, v108, s16, s16
	v_pk_mul_f32 v[96:97], v[96:97], v[104:105]
	v_pk_mul_f32 v[98:99], v[102:103], v[106:107]
	v_pk_mul_f32 v[96:97], v[100:101], v[96:97]
	v_pk_add_f32 v[100:101], v[108:109], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v104, 0
	v_pk_mul_f32 v[98:99], v[100:101], v[98:99]
	v_cmp_gt_i32_e64 s[0:1], s25, v115
	v_maximum3_f32 v100, |v97|, |v99|, |v99|
	v_maximum3_f32 v101, |v96|, |v98|, |v98|
	v_minimum3_f32 v84, v84, s17, s17
	v_max_u32_dpp v100, v100, v100 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v101, v101, v101 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v93, v93, s17, s17
	v_max_u32_dpp v100, v100, v100 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v101, v101, v101 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v85, v85, s17, s17
	v_max_u32_dpp v100, v100, v100 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v102, v101, v101 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v88, v88, s17, s17
	v_max_u32_dpp v101, v100, v100 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v100, v102, v102 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[100:101], v[100:101], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v89, v89, s17, s17
	v_add_u32_e32 v100, 0x7fffff, v100
	v_add_u32_e32 v101, 0x7fffff, v101
	v_lshrrev_b32_e32 v100, 23, v100
	v_lshrrev_b32_e32 v101, 23, v101
	v_min_u32_sdwa v100, v100, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v101, v101, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v103, 23, v100
	v_lshlrev_b32_e32 v102, 23, v101
	v_cvt_scalef32_pk_fp4_f32 v104, v96, v98, v103
	v_mov_b32_e32 v96, 0
	v_cvt_scalef32_pk_fp4_f32 v96, v97, v99, v102
	v_add_u32_e32 v97, s33, v115
	v_mul_lo_u32 v98, v97, s13
	v_add_u32_e32 v98, s15, v98
	v_or_b32_e32 v98, v98, v128
	v_cndmask_b32_e64 v98, v129, v98, s[0:1]
	buffer_store_byte v104, v113, s[8:11], 0 offen
	buffer_store_byte v100, v114, s[4:7], 0 offen
	buffer_store_byte v96, v98, s[8:11], 0 offen
	v_mad_u64_u32 v[96:97], s[2:3], v97, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v96, v129, v96, s[0:1]
	buffer_store_byte v101, v96, s[4:7], 0 offen
	v_or_b32_e32 v96, 32, v130
	v_add_u32_e32 v97, s33, v96
	v_mul_lo_u32 v98, v97, s13
	v_add_u32_e32 v98, s15, v98
	v_or_b32_e32 v98, v98, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v96
	v_mad_u64_u32 v[96:97], s[2:3], v97, 48, s[24:25]
	v_mov_b32_e32 v97, v84
	v_cndmask_b32_e64 v102, v129, v98, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v103, v129, v96, s[0:1]
	v_mov_b32_e32 v96, v92
	v_pk_mul_f32 v[96:97], v[96:97], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v100, v80, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v97
	v_cmp_gt_f32_e64 s[2:3], s18, v96
	v_minimum3_f32 v99, v81, s17, s17
	v_cndmask_b32_e64 v98, 0, v116, s[0:1]
	v_add_f32_e32 v97, v97, v98
	v_cndmask_b32_e64 v98, 0, v116, s[2:3]
	v_exp_f32_e32 v97, v97
	v_add_f32_e32 v96, v96, v98
	v_exp_f32_e32 v96, v96
	v_cndmask_b32_e64 v98, 0, v117, s[0:1]
	v_ldexp_f32 v97, v97, v98
	v_cndmask_b32_e64 v98, 0, v117, s[2:3]
	v_mov_b32_e32 v80, v93
	v_mov_b32_e32 v81, v85
	v_ldexp_f32 v96, v96, v98
	v_pk_mul_f32 v[80:81], v[80:81], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[96:97], v[96:97], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v81
	v_rcp_f32_e32 v98, v97
	v_cmp_gt_f32_e64 s[2:3], s18, v80
	v_cndmask_b32_e64 v97, 0, v116, s[0:1]
	v_add_f32_e32 v81, v81, v97
	v_cndmask_b32_e64 v97, 0, v116, s[2:3]
	v_exp_f32_e32 v81, v81
	v_add_f32_e32 v80, v80, v97
	v_exp_f32_e32 v80, v80
	v_cndmask_b32_e64 v97, 0, v117, s[0:1]
	v_ldexp_f32 v81, v81, v97
	v_cndmask_b32_e64 v97, 0, v117, s[2:3]
	v_ldexp_f32 v80, v80, v97
	v_pk_add_f32 v[80:81], v[80:81], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v96, v96
	v_rcp_f32_e32 v97, v80
	v_maximum3_f32 v101, v99, s16, s16
	v_rcp_f32_e32 v99, v81
	v_maximum3_f32 v89, v89, s16, s16
	v_maximum3_f32 v88, v88, s16, s16
	v_pk_add_f32 v[88:89], v[88:89], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v100, v100, s16, s16
	v_pk_mul_f32 v[80:81], v[92:93], v[96:97]
	v_pk_mul_f32 v[84:85], v[84:85], v[98:99]
	v_pk_mul_f32 v[80:81], v[88:89], v[80:81]
	v_pk_add_f32 v[88:89], v[100:101], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v96, 0
	v_pk_mul_f32 v[84:85], v[88:89], v[84:85]
	v_or_b32_e32 v104, 33, v130
	v_maximum3_f32 v88, |v81|, |v85|, |v85|
	v_maximum3_f32 v89, |v80|, |v84|, |v84|
	v_cmp_gt_i32_e64 s[0:1], s25, v104
	v_max_u32_dpp v88, v88, v88 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v89, v89, v89 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v86, v86, s17, s17
	v_max_u32_dpp v88, v88, v88 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v89, v89, v89 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v87, v87, s17, s17
	v_max_u32_dpp v88, v88, v88 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v92, v89, v89 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v98, 35, v130
	v_max_u32_dpp v89, v88, v88 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v88, v92, v92 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[88:89], v[88:89], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v76, v76, s17, s17
	v_add_u32_e32 v88, 0x7fffff, v88
	v_add_u32_e32 v89, 0x7fffff, v89
	v_lshrrev_b32_e32 v88, 23, v88
	v_lshrrev_b32_e32 v89, 23, v89
	v_min_u32_sdwa v88, v88, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v89, v89, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v93, 23, v88
	v_lshlrev_b32_e32 v92, 23, v89
	v_cvt_scalef32_pk_fp4_f32 v96, v80, v84, v93
	v_mov_b32_e32 v80, 0
	v_cvt_scalef32_pk_fp4_f32 v80, v81, v85, v92
	v_add_u32_e32 v81, s33, v104
	v_mul_lo_u32 v84, v81, s13
	v_add_u32_e32 v84, s15, v84
	v_or_b32_e32 v84, v84, v128
	v_cndmask_b32_e64 v84, v129, v84, s[0:1]
	buffer_store_byte v96, v102, s[8:11], 0 offen
	buffer_store_byte v88, v103, s[4:7], 0 offen
	buffer_store_byte v80, v84, s[8:11], 0 offen
	v_mad_u64_u32 v[80:81], s[2:3], v81, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v80, v129, v80, s[0:1]
	buffer_store_byte v89, v80, s[4:7], 0 offen
	v_or_b32_e32 v80, 34, v130
	v_add_u32_e32 v81, s33, v80
	v_mul_lo_u32 v84, v81, s13
	v_add_u32_e32 v84, s15, v84
	v_or_b32_e32 v84, v84, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v80
	v_mad_u64_u32 v[80:81], s[2:3], v81, 48, s[24:25]
	v_mov_b32_e32 v89, v86
	v_cndmask_b32_e64 v96, v129, v84, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v97, v129, v80, s[0:1]
	v_minimum3_f32 v80, v94, s17, s17
	v_mov_b32_e32 v88, v80
	v_pk_mul_f32 v[88:89], v[88:89], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v84, v90, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v89
	v_cmp_gt_f32_e64 s[2:3], s18, v88
	v_minimum3_f32 v81, v95, s17, s17
	v_cndmask_b32_e64 v90, 0, v116, s[0:1]
	v_add_f32_e32 v89, v89, v90
	v_cndmask_b32_e64 v90, 0, v116, s[2:3]
	v_exp_f32_e32 v89, v89
	v_add_f32_e32 v88, v88, v90
	v_exp_f32_e32 v88, v88
	v_cndmask_b32_e64 v90, 0, v117, s[0:1]
	v_minimum3_f32 v85, v91, s17, s17
	v_ldexp_f32 v89, v89, v90
	v_cndmask_b32_e64 v90, 0, v117, s[2:3]
	v_minimum3_f32 v92, v82, s17, s17
	v_minimum3_f32 v91, v83, s17, s17
	v_mov_b32_e32 v82, v81
	v_mov_b32_e32 v83, v87
	v_ldexp_f32 v88, v88, v90
	v_pk_mul_f32 v[82:83], v[82:83], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[88:89], v[88:89], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v83
	v_rcp_f32_e32 v90, v89
	v_cmp_gt_f32_e64 s[2:3], s18, v82
	v_cndmask_b32_e64 v89, 0, v116, s[0:1]
	v_add_f32_e32 v83, v83, v89
	v_cndmask_b32_e64 v89, 0, v116, s[2:3]
	v_exp_f32_e32 v83, v83
	v_add_f32_e32 v82, v82, v89
	v_exp_f32_e32 v82, v82
	v_cndmask_b32_e64 v89, 0, v117, s[0:1]
	v_ldexp_f32 v83, v83, v89
	v_cndmask_b32_e64 v89, 0, v117, s[2:3]
	v_ldexp_f32 v82, v82, v89
	v_pk_add_f32 v[82:83], v[82:83], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v88, v88
	v_rcp_f32_e32 v89, v82
	v_maximum3_f32 v93, v91, s16, s16
	v_rcp_f32_e32 v91, v83
	v_maximum3_f32 v85, v85, s16, s16
	v_maximum3_f32 v84, v84, s16, s16
	v_pk_add_f32 v[84:85], v[84:85], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v92, v92, s16, s16
	v_pk_mul_f32 v[80:81], v[80:81], v[88:89]
	v_pk_mul_f32 v[82:83], v[86:87], v[90:91]
	v_pk_mul_f32 v[80:81], v[84:85], v[80:81]
	v_pk_add_f32 v[84:85], v[92:93], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v88, 0
	v_pk_mul_f32 v[82:83], v[84:85], v[82:83]
	v_cmp_gt_i32_e64 s[0:1], s25, v98
	v_maximum3_f32 v84, |v81|, |v83|, |v83|
	v_maximum3_f32 v85, |v80|, |v82|, |v82|
	v_minimum3_f32 v68, v68, s17, s17
	v_max_u32_dpp v84, v84, v84 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v85, v85, v85 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v77, v77, s17, s17
	v_max_u32_dpp v84, v84, v84 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v85, v85, v85 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v69, v69, s17, s17
	v_max_u32_dpp v84, v84, v84 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v86, v85, v85 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v72, v72, s17, s17
	v_max_u32_dpp v85, v84, v84 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v84, v86, v86 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[84:85], v[84:85], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v73, v73, s17, s17
	v_add_u32_e32 v84, 0x7fffff, v84
	v_add_u32_e32 v85, 0x7fffff, v85
	v_lshrrev_b32_e32 v84, 23, v84
	v_lshrrev_b32_e32 v85, 23, v85
	v_min_u32_sdwa v84, v84, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v85, v85, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v87, 23, v84
	v_lshlrev_b32_e32 v86, 23, v85
	v_cvt_scalef32_pk_fp4_f32 v88, v80, v82, v87
	v_mov_b32_e32 v80, 0
	v_cvt_scalef32_pk_fp4_f32 v80, v81, v83, v86
	v_add_u32_e32 v81, s33, v98
	v_mul_lo_u32 v82, v81, s13
	v_add_u32_e32 v82, s15, v82
	v_or_b32_e32 v82, v82, v128
	v_cndmask_b32_e64 v82, v129, v82, s[0:1]
	buffer_store_byte v88, v96, s[8:11], 0 offen
	buffer_store_byte v84, v97, s[4:7], 0 offen
	buffer_store_byte v80, v82, s[8:11], 0 offen
	v_mad_u64_u32 v[80:81], s[2:3], v81, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v80, v129, v80, s[0:1]
	buffer_store_byte v85, v80, s[4:7], 0 offen
	v_or_b32_e32 v80, 48, v130
	v_add_u32_e32 v81, s33, v80
	v_mul_lo_u32 v82, v81, s13
	v_add_u32_e32 v82, s15, v82
	v_or_b32_e32 v82, v82, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v80
	v_mad_u64_u32 v[80:81], s[2:3], v81, 48, s[24:25]
	v_mov_b32_e32 v81, v68
	v_cndmask_b32_e64 v86, v129, v82, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v87, v129, v80, s[0:1]
	v_mov_b32_e32 v80, v76
	v_pk_mul_f32 v[80:81], v[80:81], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v84, v64, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v81
	v_cmp_gt_f32_e64 s[2:3], s18, v80
	v_minimum3_f32 v83, v65, s17, s17
	v_cndmask_b32_e64 v82, 0, v116, s[0:1]
	v_add_f32_e32 v81, v81, v82
	v_cndmask_b32_e64 v82, 0, v116, s[2:3]
	v_exp_f32_e32 v81, v81
	v_add_f32_e32 v80, v80, v82
	v_exp_f32_e32 v80, v80
	v_cndmask_b32_e64 v82, 0, v117, s[0:1]
	v_ldexp_f32 v81, v81, v82
	v_cndmask_b32_e64 v82, 0, v117, s[2:3]
	v_mov_b32_e32 v64, v77
	v_mov_b32_e32 v65, v69
	v_ldexp_f32 v80, v80, v82
	v_pk_mul_f32 v[64:65], v[64:65], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[80:81], v[80:81], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v65
	v_rcp_f32_e32 v82, v81
	v_cmp_gt_f32_e64 s[2:3], s18, v64
	v_cndmask_b32_e64 v81, 0, v116, s[0:1]
	v_add_f32_e32 v65, v65, v81
	v_cndmask_b32_e64 v81, 0, v116, s[2:3]
	v_exp_f32_e32 v65, v65
	v_add_f32_e32 v64, v64, v81
	v_exp_f32_e32 v64, v64
	v_cndmask_b32_e64 v81, 0, v117, s[0:1]
	v_ldexp_f32 v65, v65, v81
	v_cndmask_b32_e64 v81, 0, v117, s[2:3]
	v_ldexp_f32 v64, v64, v81
	v_pk_add_f32 v[64:65], v[64:65], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v80, v80
	v_rcp_f32_e32 v81, v64
	v_maximum3_f32 v85, v83, s16, s16
	v_rcp_f32_e32 v83, v65
	v_maximum3_f32 v73, v73, s16, s16
	v_maximum3_f32 v72, v72, s16, s16
	v_pk_add_f32 v[72:73], v[72:73], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v84, v84, s16, s16
	v_pk_mul_f32 v[64:65], v[76:77], v[80:81]
	v_pk_mul_f32 v[68:69], v[68:69], v[82:83]
	v_pk_mul_f32 v[64:65], v[72:73], v[64:65]
	v_pk_add_f32 v[72:73], v[84:85], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v80, 0
	v_pk_mul_f32 v[68:69], v[72:73], v[68:69]
	v_or_b32_e32 v88, 49, v130
	v_maximum3_f32 v72, |v65|, |v69|, |v69|
	v_maximum3_f32 v73, |v64|, |v68|, |v68|
	v_cmp_gt_i32_e64 s[0:1], s25, v88
	v_max_u32_dpp v72, v72, v72 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v73, v73, v73 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v70, v70, s17, s17
	v_max_u32_dpp v72, v72, v72 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v73, v73, v73 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v71, v71, s17, s17
	v_max_u32_dpp v72, v72, v72 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v76, v73, v73 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v82, 51, v130
	v_max_u32_dpp v73, v72, v72 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v72, v76, v76 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[72:73], v[72:73], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v60, v60, s17, s17
	v_add_u32_e32 v72, 0x7fffff, v72
	v_add_u32_e32 v73, 0x7fffff, v73
	v_lshrrev_b32_e32 v72, 23, v72
	v_lshrrev_b32_e32 v73, 23, v73
	v_min_u32_sdwa v72, v72, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v73, v73, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v77, 23, v72
	v_lshlrev_b32_e32 v76, 23, v73
	v_cvt_scalef32_pk_fp4_f32 v80, v64, v68, v77
	v_mov_b32_e32 v64, 0
	v_cvt_scalef32_pk_fp4_f32 v64, v65, v69, v76
	v_add_u32_e32 v65, s33, v88
	v_mul_lo_u32 v68, v65, s13
	v_add_u32_e32 v68, s15, v68
	v_or_b32_e32 v68, v68, v128
	v_cndmask_b32_e64 v68, v129, v68, s[0:1]
	buffer_store_byte v80, v86, s[8:11], 0 offen
	buffer_store_byte v72, v87, s[4:7], 0 offen
	buffer_store_byte v64, v68, s[8:11], 0 offen
	v_mad_u64_u32 v[64:65], s[2:3], v65, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v64, v129, v64, s[0:1]
	buffer_store_byte v73, v64, s[4:7], 0 offen
	v_or_b32_e32 v64, 50, v130
	v_add_u32_e32 v65, s33, v64
	v_mul_lo_u32 v68, v65, s13
	v_add_u32_e32 v68, s15, v68
	v_or_b32_e32 v68, v68, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v64
	v_mad_u64_u32 v[64:65], s[2:3], v65, 48, s[24:25]
	v_mov_b32_e32 v73, v70
	v_cndmask_b32_e64 v80, v129, v68, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v81, v129, v64, s[0:1]
	v_minimum3_f32 v64, v78, s17, s17
	v_mov_b32_e32 v72, v64
	v_pk_mul_f32 v[72:73], v[72:73], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v68, v74, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v73
	v_cmp_gt_f32_e64 s[2:3], s18, v72
	v_minimum3_f32 v65, v79, s17, s17
	v_cndmask_b32_e64 v74, 0, v116, s[0:1]
	v_add_f32_e32 v73, v73, v74
	v_cndmask_b32_e64 v74, 0, v116, s[2:3]
	v_exp_f32_e32 v73, v73
	v_add_f32_e32 v72, v72, v74
	v_exp_f32_e32 v72, v72
	v_cndmask_b32_e64 v74, 0, v117, s[0:1]
	v_minimum3_f32 v69, v75, s17, s17
	v_ldexp_f32 v73, v73, v74
	v_cndmask_b32_e64 v74, 0, v117, s[2:3]
	v_minimum3_f32 v76, v66, s17, s17
	v_minimum3_f32 v75, v67, s17, s17
	v_mov_b32_e32 v66, v65
	v_mov_b32_e32 v67, v71
	v_ldexp_f32 v72, v72, v74
	v_pk_mul_f32 v[66:67], v[66:67], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[72:73], v[72:73], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v67
	v_rcp_f32_e32 v74, v73
	v_cmp_gt_f32_e64 s[2:3], s18, v66
	v_cndmask_b32_e64 v73, 0, v116, s[0:1]
	v_add_f32_e32 v67, v67, v73
	v_cndmask_b32_e64 v73, 0, v116, s[2:3]
	v_exp_f32_e32 v67, v67
	v_add_f32_e32 v66, v66, v73
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v73, 0, v117, s[0:1]
	v_ldexp_f32 v67, v67, v73
	v_cndmask_b32_e64 v73, 0, v117, s[2:3]
	v_ldexp_f32 v66, v66, v73
	v_pk_add_f32 v[66:67], v[66:67], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v72, v72
	v_rcp_f32_e32 v73, v66
	v_maximum3_f32 v77, v75, s16, s16
	v_rcp_f32_e32 v75, v67
	v_maximum3_f32 v69, v69, s16, s16
	v_maximum3_f32 v68, v68, s16, s16
	v_pk_add_f32 v[68:69], v[68:69], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v76, v76, s16, s16
	v_pk_mul_f32 v[64:65], v[64:65], v[72:73]
	v_pk_mul_f32 v[66:67], v[70:71], v[74:75]
	v_pk_mul_f32 v[64:65], v[68:69], v[64:65]
	v_pk_add_f32 v[68:69], v[76:77], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v72, 0
	v_pk_mul_f32 v[66:67], v[68:69], v[66:67]
	v_cmp_gt_i32_e64 s[0:1], s25, v82
	v_maximum3_f32 v68, |v65|, |v67|, |v67|
	v_maximum3_f32 v69, |v64|, |v66|, |v66|
	v_minimum3_f32 v52, v52, s17, s17
	v_max_u32_dpp v68, v68, v68 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v69, v69, v69 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v61, v61, s17, s17
	v_max_u32_dpp v68, v68, v68 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v69, v69, v69 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v53, v53, s17, s17
	v_max_u32_dpp v68, v68, v68 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v70, v69, v69 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v56, v56, s17, s17
	v_max_u32_dpp v69, v68, v68 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v68, v70, v70 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[68:69], v[68:69], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v57, v57, s17, s17
	v_add_u32_e32 v68, 0x7fffff, v68
	v_add_u32_e32 v69, 0x7fffff, v69
	v_lshrrev_b32_e32 v68, 23, v68
	v_lshrrev_b32_e32 v69, 23, v69
	v_min_u32_sdwa v68, v68, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v69, v69, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v71, 23, v68
	v_lshlrev_b32_e32 v70, 23, v69
	v_cvt_scalef32_pk_fp4_f32 v72, v64, v66, v71
	v_mov_b32_e32 v64, 0
	v_cvt_scalef32_pk_fp4_f32 v64, v65, v67, v70
	v_add_u32_e32 v65, s33, v82
	v_mul_lo_u32 v66, v65, s13
	v_add_u32_e32 v66, s15, v66
	v_or_b32_e32 v66, v66, v128
	v_cndmask_b32_e64 v66, v129, v66, s[0:1]
	buffer_store_byte v72, v80, s[8:11], 0 offen
	buffer_store_byte v68, v81, s[4:7], 0 offen
	buffer_store_byte v64, v66, s[8:11], 0 offen
	v_mad_u64_u32 v[64:65], s[2:3], v65, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v64, v129, v64, s[0:1]
	buffer_store_byte v69, v64, s[4:7], 0 offen
	v_or_b32_e32 v64, 64, v130
	v_add_u32_e32 v65, s33, v64
	v_mul_lo_u32 v66, v65, s13
	v_add_u32_e32 v66, s15, v66
	v_or_b32_e32 v66, v66, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v64
	v_mad_u64_u32 v[64:65], s[2:3], v65, 48, s[24:25]
	v_mov_b32_e32 v65, v52
	v_cndmask_b32_e64 v70, v129, v66, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v71, v129, v64, s[0:1]
	v_mov_b32_e32 v64, v60
	v_pk_mul_f32 v[64:65], v[64:65], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v68, v48, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v65
	v_cmp_gt_f32_e64 s[2:3], s18, v64
	v_minimum3_f32 v67, v49, s17, s17
	v_cndmask_b32_e64 v66, 0, v116, s[0:1]
	v_add_f32_e32 v65, v65, v66
	v_cndmask_b32_e64 v66, 0, v116, s[2:3]
	v_exp_f32_e32 v65, v65
	v_add_f32_e32 v64, v64, v66
	v_exp_f32_e32 v64, v64
	v_cndmask_b32_e64 v66, 0, v117, s[0:1]
	v_ldexp_f32 v65, v65, v66
	v_cndmask_b32_e64 v66, 0, v117, s[2:3]
	v_mov_b32_e32 v48, v61
	v_mov_b32_e32 v49, v53
	v_ldexp_f32 v64, v64, v66
	v_pk_mul_f32 v[48:49], v[48:49], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[64:65], v[64:65], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v49
	v_rcp_f32_e32 v66, v65
	v_cmp_gt_f32_e64 s[2:3], s18, v48
	v_cndmask_b32_e64 v65, 0, v116, s[0:1]
	v_add_f32_e32 v49, v49, v65
	v_cndmask_b32_e64 v65, 0, v116, s[2:3]
	v_exp_f32_e32 v49, v49
	v_add_f32_e32 v48, v48, v65
	v_exp_f32_e32 v48, v48
	v_cndmask_b32_e64 v65, 0, v117, s[0:1]
	v_ldexp_f32 v49, v49, v65
	v_cndmask_b32_e64 v65, 0, v117, s[2:3]
	v_ldexp_f32 v48, v48, v65
	v_pk_add_f32 v[48:49], v[48:49], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v64, v64
	v_rcp_f32_e32 v65, v48
	v_maximum3_f32 v69, v67, s16, s16
	v_rcp_f32_e32 v67, v49
	v_maximum3_f32 v57, v57, s16, s16
	v_maximum3_f32 v56, v56, s16, s16
	v_pk_add_f32 v[56:57], v[56:57], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v68, v68, s16, s16
	v_pk_mul_f32 v[48:49], v[60:61], v[64:65]
	v_pk_mul_f32 v[52:53], v[52:53], v[66:67]
	v_pk_mul_f32 v[48:49], v[56:57], v[48:49]
	v_pk_add_f32 v[56:57], v[68:69], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v64, 0
	v_pk_mul_f32 v[52:53], v[56:57], v[52:53]
	v_or_b32_e32 v72, 0x41, v130
	v_maximum3_f32 v56, |v49|, |v53|, |v53|
	v_maximum3_f32 v57, |v48|, |v52|, |v52|
	v_cmp_gt_i32_e64 s[0:1], s25, v72
	v_max_u32_dpp v56, v56, v56 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v57, v57, v57 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v54, v54, s17, s17
	v_max_u32_dpp v56, v56, v56 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v57, v57, v57 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v55, v55, s17, s17
	v_max_u32_dpp v56, v56, v56 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v60, v57, v57 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v66, 0x43, v130
	v_max_u32_dpp v57, v56, v56 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v56, v60, v60 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[56:57], v[56:57], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v44, v44, s17, s17
	v_add_u32_e32 v56, 0x7fffff, v56
	v_add_u32_e32 v57, 0x7fffff, v57
	v_lshrrev_b32_e32 v56, 23, v56
	v_lshrrev_b32_e32 v57, 23, v57
	v_min_u32_sdwa v56, v56, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v57, v57, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v61, 23, v56
	v_lshlrev_b32_e32 v60, 23, v57
	v_cvt_scalef32_pk_fp4_f32 v64, v48, v52, v61
	v_mov_b32_e32 v48, 0
	v_cvt_scalef32_pk_fp4_f32 v48, v49, v53, v60
	v_add_u32_e32 v49, s33, v72
	v_mul_lo_u32 v52, v49, s13
	v_add_u32_e32 v52, s15, v52
	v_or_b32_e32 v52, v52, v128
	v_cndmask_b32_e64 v52, v129, v52, s[0:1]
	buffer_store_byte v64, v70, s[8:11], 0 offen
	buffer_store_byte v56, v71, s[4:7], 0 offen
	buffer_store_byte v48, v52, s[8:11], 0 offen
	v_mad_u64_u32 v[48:49], s[2:3], v49, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v48, v129, v48, s[0:1]
	buffer_store_byte v57, v48, s[4:7], 0 offen
	v_or_b32_e32 v48, 0x42, v130
	v_add_u32_e32 v49, s33, v48
	v_mul_lo_u32 v52, v49, s13
	v_add_u32_e32 v52, s15, v52
	v_or_b32_e32 v52, v52, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v48
	v_mad_u64_u32 v[48:49], s[2:3], v49, 48, s[24:25]
	v_mov_b32_e32 v57, v54
	v_cndmask_b32_e64 v64, v129, v52, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v65, v129, v48, s[0:1]
	v_minimum3_f32 v48, v62, s17, s17
	v_mov_b32_e32 v56, v48
	v_pk_mul_f32 v[56:57], v[56:57], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v52, v58, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v57
	v_cmp_gt_f32_e64 s[2:3], s18, v56
	v_minimum3_f32 v49, v63, s17, s17
	v_cndmask_b32_e64 v58, 0, v116, s[0:1]
	v_add_f32_e32 v57, v57, v58
	v_cndmask_b32_e64 v58, 0, v116, s[2:3]
	v_exp_f32_e32 v57, v57
	v_add_f32_e32 v56, v56, v58
	v_exp_f32_e32 v56, v56
	v_cndmask_b32_e64 v58, 0, v117, s[0:1]
	v_minimum3_f32 v53, v59, s17, s17
	v_ldexp_f32 v57, v57, v58
	v_cndmask_b32_e64 v58, 0, v117, s[2:3]
	v_minimum3_f32 v60, v50, s17, s17
	v_minimum3_f32 v59, v51, s17, s17
	v_mov_b32_e32 v50, v49
	v_mov_b32_e32 v51, v55
	v_ldexp_f32 v56, v56, v58
	v_pk_mul_f32 v[50:51], v[50:51], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[56:57], v[56:57], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v51
	v_rcp_f32_e32 v58, v57
	v_cmp_gt_f32_e64 s[2:3], s18, v50
	v_cndmask_b32_e64 v57, 0, v116, s[0:1]
	v_add_f32_e32 v51, v51, v57
	v_cndmask_b32_e64 v57, 0, v116, s[2:3]
	v_exp_f32_e32 v51, v51
	v_add_f32_e32 v50, v50, v57
	v_exp_f32_e32 v50, v50
	v_cndmask_b32_e64 v57, 0, v117, s[0:1]
	v_ldexp_f32 v51, v51, v57
	v_cndmask_b32_e64 v57, 0, v117, s[2:3]
	v_ldexp_f32 v50, v50, v57
	v_pk_add_f32 v[50:51], v[50:51], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v56, v56
	v_rcp_f32_e32 v57, v50
	v_maximum3_f32 v61, v59, s16, s16
	v_rcp_f32_e32 v59, v51
	v_maximum3_f32 v53, v53, s16, s16
	v_maximum3_f32 v52, v52, s16, s16
	v_pk_add_f32 v[52:53], v[52:53], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v60, v60, s16, s16
	v_pk_mul_f32 v[48:49], v[48:49], v[56:57]
	v_pk_mul_f32 v[50:51], v[54:55], v[58:59]
	v_pk_mul_f32 v[48:49], v[52:53], v[48:49]
	v_pk_add_f32 v[52:53], v[60:61], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v56, 0
	v_pk_mul_f32 v[50:51], v[52:53], v[50:51]
	v_cmp_gt_i32_e64 s[0:1], s25, v66
	v_maximum3_f32 v52, |v49|, |v51|, |v51|
	v_maximum3_f32 v53, |v48|, |v50|, |v50|
	v_minimum3_f32 v36, v36, s17, s17
	v_max_u32_dpp v52, v52, v52 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v53, v53, v53 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v45, v45, s17, s17
	v_max_u32_dpp v52, v52, v52 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v53, v53, v53 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v37, v37, s17, s17
	v_max_u32_dpp v52, v52, v52 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v54, v53, v53 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v40, v40, s17, s17
	v_max_u32_dpp v53, v52, v52 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v52, v54, v54 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[52:53], v[52:53], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v41, v41, s17, s17
	v_add_u32_e32 v52, 0x7fffff, v52
	v_add_u32_e32 v53, 0x7fffff, v53
	v_lshrrev_b32_e32 v52, 23, v52
	v_lshrrev_b32_e32 v53, 23, v53
	v_min_u32_sdwa v52, v52, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v53, v53, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v55, 23, v52
	v_lshlrev_b32_e32 v54, 23, v53
	v_cvt_scalef32_pk_fp4_f32 v56, v48, v50, v55
	v_mov_b32_e32 v48, 0
	v_cvt_scalef32_pk_fp4_f32 v48, v49, v51, v54
	v_add_u32_e32 v49, s33, v66
	v_mul_lo_u32 v50, v49, s13
	v_add_u32_e32 v50, s15, v50
	v_or_b32_e32 v50, v50, v128
	v_cndmask_b32_e64 v50, v129, v50, s[0:1]
	buffer_store_byte v56, v64, s[8:11], 0 offen
	buffer_store_byte v52, v65, s[4:7], 0 offen
	buffer_store_byte v48, v50, s[8:11], 0 offen
	v_mad_u64_u32 v[48:49], s[2:3], v49, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v48, v129, v48, s[0:1]
	buffer_store_byte v53, v48, s[4:7], 0 offen
	v_or_b32_e32 v48, 0x50, v130
	v_add_u32_e32 v49, s33, v48
	v_mul_lo_u32 v50, v49, s13
	v_add_u32_e32 v50, s15, v50
	v_or_b32_e32 v50, v50, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v48
	v_mad_u64_u32 v[48:49], s[2:3], v49, 48, s[24:25]
	v_mov_b32_e32 v49, v36
	v_cndmask_b32_e64 v54, v129, v50, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v55, v129, v48, s[0:1]
	v_mov_b32_e32 v48, v44
	v_pk_mul_f32 v[48:49], v[48:49], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v52, v32, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v49
	v_cmp_gt_f32_e64 s[2:3], s18, v48
	v_minimum3_f32 v51, v33, s17, s17
	v_cndmask_b32_e64 v50, 0, v116, s[0:1]
	v_add_f32_e32 v49, v49, v50
	v_cndmask_b32_e64 v50, 0, v116, s[2:3]
	v_exp_f32_e32 v49, v49
	v_add_f32_e32 v48, v48, v50
	v_exp_f32_e32 v48, v48
	v_cndmask_b32_e64 v50, 0, v117, s[0:1]
	v_ldexp_f32 v49, v49, v50
	v_cndmask_b32_e64 v50, 0, v117, s[2:3]
	v_mov_b32_e32 v32, v45
	v_mov_b32_e32 v33, v37
	v_ldexp_f32 v48, v48, v50
	v_pk_mul_f32 v[32:33], v[32:33], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[48:49], v[48:49], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v33
	v_rcp_f32_e32 v50, v49
	v_cmp_gt_f32_e64 s[2:3], s18, v32
	v_cndmask_b32_e64 v49, 0, v116, s[0:1]
	v_add_f32_e32 v33, v33, v49
	v_cndmask_b32_e64 v49, 0, v116, s[2:3]
	v_exp_f32_e32 v33, v33
	v_add_f32_e32 v32, v32, v49
	v_exp_f32_e32 v32, v32
	v_cndmask_b32_e64 v49, 0, v117, s[0:1]
	v_ldexp_f32 v33, v33, v49
	v_cndmask_b32_e64 v49, 0, v117, s[2:3]
	v_ldexp_f32 v32, v32, v49
	v_pk_add_f32 v[32:33], v[32:33], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v48, v48
	v_rcp_f32_e32 v49, v32
	v_maximum3_f32 v53, v51, s16, s16
	v_rcp_f32_e32 v51, v33
	v_maximum3_f32 v41, v41, s16, s16
	v_maximum3_f32 v40, v40, s16, s16
	v_pk_add_f32 v[40:41], v[40:41], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v52, v52, s16, s16
	v_pk_mul_f32 v[32:33], v[44:45], v[48:49]
	v_pk_mul_f32 v[36:37], v[36:37], v[50:51]
	v_pk_mul_f32 v[32:33], v[40:41], v[32:33]
	v_pk_add_f32 v[40:41], v[52:53], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v48, 0
	v_pk_mul_f32 v[36:37], v[40:41], v[36:37]
	v_or_b32_e32 v56, 0x51, v130
	v_maximum3_f32 v40, |v33|, |v37|, |v37|
	v_maximum3_f32 v41, |v32|, |v36|, |v36|
	v_cmp_gt_i32_e64 s[0:1], s25, v56
	v_max_u32_dpp v40, v40, v40 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v41, v41, v41 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v38, v38, s17, s17
	v_max_u32_dpp v40, v40, v40 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v41, v41, v41 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v39, v39, s17, s17
	v_max_u32_dpp v40, v40, v40 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v44, v41, v41 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v50, 0x53, v130
	v_max_u32_dpp v41, v40, v40 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v40, v44, v44 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[40:41], v[40:41], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v28, v28, s17, s17
	v_add_u32_e32 v40, 0x7fffff, v40
	v_add_u32_e32 v41, 0x7fffff, v41
	v_lshrrev_b32_e32 v40, 23, v40
	v_lshrrev_b32_e32 v41, 23, v41
	v_min_u32_sdwa v40, v40, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v41, v41, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v45, 23, v40
	v_lshlrev_b32_e32 v44, 23, v41
	v_cvt_scalef32_pk_fp4_f32 v48, v32, v36, v45
	v_mov_b32_e32 v32, 0
	v_cvt_scalef32_pk_fp4_f32 v32, v33, v37, v44
	v_add_u32_e32 v33, s33, v56
	v_mul_lo_u32 v36, v33, s13
	v_add_u32_e32 v36, s15, v36
	v_or_b32_e32 v36, v36, v128
	v_cndmask_b32_e64 v36, v129, v36, s[0:1]
	buffer_store_byte v48, v54, s[8:11], 0 offen
	buffer_store_byte v40, v55, s[4:7], 0 offen
	buffer_store_byte v32, v36, s[8:11], 0 offen
	v_mad_u64_u32 v[32:33], s[2:3], v33, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v32, v129, v32, s[0:1]
	buffer_store_byte v41, v32, s[4:7], 0 offen
	v_or_b32_e32 v32, 0x52, v130
	v_add_u32_e32 v33, s33, v32
	v_mul_lo_u32 v36, v33, s13
	v_add_u32_e32 v36, s15, v36
	v_or_b32_e32 v36, v36, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v32
	v_mad_u64_u32 v[32:33], s[2:3], v33, 48, s[24:25]
	v_mov_b32_e32 v41, v38
	v_cndmask_b32_e64 v48, v129, v36, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v49, v129, v32, s[0:1]
	v_minimum3_f32 v32, v46, s17, s17
	v_mov_b32_e32 v40, v32
	v_pk_mul_f32 v[40:41], v[40:41], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v36, v42, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v41
	v_cmp_gt_f32_e64 s[2:3], s18, v40
	v_minimum3_f32 v33, v47, s17, s17
	v_cndmask_b32_e64 v42, 0, v116, s[0:1]
	v_add_f32_e32 v41, v41, v42
	v_cndmask_b32_e64 v42, 0, v116, s[2:3]
	v_exp_f32_e32 v41, v41
	v_add_f32_e32 v40, v40, v42
	v_exp_f32_e32 v40, v40
	v_cndmask_b32_e64 v42, 0, v117, s[0:1]
	v_minimum3_f32 v37, v43, s17, s17
	v_ldexp_f32 v41, v41, v42
	v_cndmask_b32_e64 v42, 0, v117, s[2:3]
	v_minimum3_f32 v44, v34, s17, s17
	v_minimum3_f32 v43, v35, s17, s17
	v_mov_b32_e32 v34, v33
	v_mov_b32_e32 v35, v39
	v_ldexp_f32 v40, v40, v42
	v_pk_mul_f32 v[34:35], v[34:35], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[40:41], v[40:41], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v35
	v_rcp_f32_e32 v42, v41
	v_cmp_gt_f32_e64 s[2:3], s18, v34
	v_cndmask_b32_e64 v41, 0, v116, s[0:1]
	v_add_f32_e32 v35, v35, v41
	v_cndmask_b32_e64 v41, 0, v116, s[2:3]
	v_exp_f32_e32 v35, v35
	v_add_f32_e32 v34, v34, v41
	v_exp_f32_e32 v34, v34
	v_cndmask_b32_e64 v41, 0, v117, s[0:1]
	v_ldexp_f32 v35, v35, v41
	v_cndmask_b32_e64 v41, 0, v117, s[2:3]
	v_ldexp_f32 v34, v34, v41
	v_pk_add_f32 v[34:35], v[34:35], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v40, v40
	v_rcp_f32_e32 v41, v34
	v_maximum3_f32 v45, v43, s16, s16
	v_rcp_f32_e32 v43, v35
	v_maximum3_f32 v37, v37, s16, s16
	v_maximum3_f32 v36, v36, s16, s16
	v_pk_add_f32 v[36:37], v[36:37], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v44, v44, s16, s16
	v_pk_mul_f32 v[32:33], v[32:33], v[40:41]
	v_pk_mul_f32 v[34:35], v[38:39], v[42:43]
	v_pk_mul_f32 v[32:33], v[36:37], v[32:33]
	v_pk_add_f32 v[36:37], v[44:45], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v40, 0
	v_pk_mul_f32 v[34:35], v[36:37], v[34:35]
	v_cmp_gt_i32_e64 s[0:1], s25, v50
	v_maximum3_f32 v36, |v33|, |v35|, |v35|
	v_maximum3_f32 v37, |v32|, |v34|, |v34|
	v_minimum3_f32 v20, v20, s17, s17
	v_max_u32_dpp v36, v36, v36 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v37, v37, v37 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v29, v29, s17, s17
	v_max_u32_dpp v36, v36, v36 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v37, v37, v37 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v21, v21, s17, s17
	v_max_u32_dpp v36, v36, v36 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v38, v37, v37 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v24, v24, s17, s17
	v_max_u32_dpp v37, v36, v36 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v36, v38, v38 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[36:37], v[36:37], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v25, v25, s17, s17
	v_add_u32_e32 v36, 0x7fffff, v36
	v_add_u32_e32 v37, 0x7fffff, v37
	v_lshrrev_b32_e32 v36, 23, v36
	v_lshrrev_b32_e32 v37, 23, v37
	v_min_u32_sdwa v36, v36, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v37, v37, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v39, 23, v36
	v_lshlrev_b32_e32 v38, 23, v37
	v_cvt_scalef32_pk_fp4_f32 v40, v32, v34, v39
	v_mov_b32_e32 v32, 0
	v_cvt_scalef32_pk_fp4_f32 v32, v33, v35, v38
	v_add_u32_e32 v33, s33, v50
	v_mul_lo_u32 v34, v33, s13
	v_add_u32_e32 v34, s15, v34
	v_or_b32_e32 v34, v34, v128
	v_cndmask_b32_e64 v34, v129, v34, s[0:1]
	buffer_store_byte v40, v48, s[8:11], 0 offen
	buffer_store_byte v36, v49, s[4:7], 0 offen
	buffer_store_byte v32, v34, s[8:11], 0 offen
	v_mad_u64_u32 v[32:33], s[2:3], v33, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v32, v129, v32, s[0:1]
	buffer_store_byte v37, v32, s[4:7], 0 offen
	v_or_b32_e32 v32, 0x60, v130
	v_add_u32_e32 v33, s33, v32
	v_mul_lo_u32 v34, v33, s13
	v_add_u32_e32 v34, s15, v34
	v_or_b32_e32 v34, v34, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v32
	v_mad_u64_u32 v[32:33], s[2:3], v33, 48, s[24:25]
	v_mov_b32_e32 v33, v20
	v_cndmask_b32_e64 v38, v129, v34, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v39, v129, v32, s[0:1]
	v_mov_b32_e32 v32, v28
	v_pk_mul_f32 v[32:33], v[32:33], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v36, v16, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v33
	v_cmp_gt_f32_e64 s[2:3], s18, v32
	v_minimum3_f32 v35, v17, s17, s17
	v_cndmask_b32_e64 v34, 0, v116, s[0:1]
	v_add_f32_e32 v33, v33, v34
	v_cndmask_b32_e64 v34, 0, v116, s[2:3]
	v_exp_f32_e32 v33, v33
	v_add_f32_e32 v32, v32, v34
	v_exp_f32_e32 v32, v32
	v_cndmask_b32_e64 v34, 0, v117, s[0:1]
	v_ldexp_f32 v33, v33, v34
	v_cndmask_b32_e64 v34, 0, v117, s[2:3]
	v_mov_b32_e32 v16, v29
	v_mov_b32_e32 v17, v21
	v_ldexp_f32 v32, v32, v34
	v_pk_mul_f32 v[16:17], v[16:17], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[32:33], v[32:33], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v17
	v_rcp_f32_e32 v34, v33
	v_cmp_gt_f32_e64 s[2:3], s18, v16
	v_cndmask_b32_e64 v33, 0, v116, s[0:1]
	v_add_f32_e32 v17, v17, v33
	v_cndmask_b32_e64 v33, 0, v116, s[2:3]
	v_exp_f32_e32 v17, v17
	v_add_f32_e32 v16, v16, v33
	v_exp_f32_e32 v16, v16
	v_cndmask_b32_e64 v33, 0, v117, s[0:1]
	v_ldexp_f32 v17, v17, v33
	v_cndmask_b32_e64 v33, 0, v117, s[2:3]
	v_ldexp_f32 v16, v16, v33
	v_pk_add_f32 v[16:17], v[16:17], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v32, v32
	v_rcp_f32_e32 v33, v16
	v_maximum3_f32 v37, v35, s16, s16
	v_rcp_f32_e32 v35, v17
	v_maximum3_f32 v25, v25, s16, s16
	v_maximum3_f32 v24, v24, s16, s16
	v_pk_add_f32 v[24:25], v[24:25], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v36, v36, s16, s16
	v_pk_mul_f32 v[16:17], v[28:29], v[32:33]
	v_pk_mul_f32 v[20:21], v[20:21], v[34:35]
	v_pk_mul_f32 v[16:17], v[24:25], v[16:17]
	v_pk_add_f32 v[24:25], v[36:37], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v32, 0
	v_pk_mul_f32 v[20:21], v[24:25], v[20:21]
	v_or_b32_e32 v40, 0x61, v130
	v_maximum3_f32 v24, |v17|, |v21|, |v21|
	v_maximum3_f32 v25, |v16|, |v20|, |v20|
	v_cmp_gt_i32_e64 s[0:1], s25, v40
	v_max_u32_dpp v24, v24, v24 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v25, v25, v25 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v22, v22, s17, s17
	v_max_u32_dpp v24, v24, v24 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v25, v25, v25 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v23, v23, s17, s17
	v_max_u32_dpp v24, v24, v24 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v28, v25, v25 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v34, 0x63, v130
	v_max_u32_dpp v25, v24, v24 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v24, v28, v28 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[24:25], v[24:25], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v12, v12, s17, s17
	v_add_u32_e32 v24, 0x7fffff, v24
	v_add_u32_e32 v25, 0x7fffff, v25
	v_lshrrev_b32_e32 v24, 23, v24
	v_lshrrev_b32_e32 v25, 23, v25
	v_min_u32_sdwa v24, v24, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v25, v25, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v29, 23, v24
	v_lshlrev_b32_e32 v28, 23, v25
	v_cvt_scalef32_pk_fp4_f32 v32, v16, v20, v29
	v_mov_b32_e32 v16, 0
	v_cvt_scalef32_pk_fp4_f32 v16, v17, v21, v28
	v_add_u32_e32 v17, s33, v40
	v_mul_lo_u32 v20, v17, s13
	v_add_u32_e32 v20, s15, v20
	v_or_b32_e32 v20, v20, v128
	v_cndmask_b32_e64 v20, v129, v20, s[0:1]
	buffer_store_byte v32, v38, s[8:11], 0 offen
	buffer_store_byte v24, v39, s[4:7], 0 offen
	buffer_store_byte v16, v20, s[8:11], 0 offen
	v_mad_u64_u32 v[16:17], s[2:3], v17, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v16, v129, v16, s[0:1]
	buffer_store_byte v25, v16, s[4:7], 0 offen
	v_or_b32_e32 v16, 0x62, v130
	v_add_u32_e32 v17, s33, v16
	v_mul_lo_u32 v20, v17, s13
	v_add_u32_e32 v20, s15, v20
	v_or_b32_e32 v20, v20, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v16
	v_mad_u64_u32 v[16:17], s[2:3], v17, 48, s[24:25]
	v_mov_b32_e32 v25, v22
	v_cndmask_b32_e64 v32, v129, v20, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v33, v129, v16, s[0:1]
	v_minimum3_f32 v16, v30, s17, s17
	v_mov_b32_e32 v24, v16
	v_pk_mul_f32 v[24:25], v[24:25], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v20, v26, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v25
	v_cmp_gt_f32_e64 s[2:3], s18, v24
	v_minimum3_f32 v17, v31, s17, s17
	v_cndmask_b32_e64 v26, 0, v116, s[0:1]
	v_add_f32_e32 v25, v25, v26
	v_cndmask_b32_e64 v26, 0, v116, s[2:3]
	v_exp_f32_e32 v25, v25
	v_add_f32_e32 v24, v24, v26
	v_exp_f32_e32 v24, v24
	v_cndmask_b32_e64 v26, 0, v117, s[0:1]
	v_minimum3_f32 v21, v27, s17, s17
	v_ldexp_f32 v25, v25, v26
	v_cndmask_b32_e64 v26, 0, v117, s[2:3]
	v_minimum3_f32 v28, v18, s17, s17
	v_minimum3_f32 v27, v19, s17, s17
	v_mov_b32_e32 v18, v17
	v_mov_b32_e32 v19, v23
	v_ldexp_f32 v24, v24, v26
	v_pk_mul_f32 v[18:19], v[18:19], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[24:25], v[24:25], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v19
	v_rcp_f32_e32 v26, v25
	v_cmp_gt_f32_e64 s[2:3], s18, v18
	v_cndmask_b32_e64 v25, 0, v116, s[0:1]
	v_add_f32_e32 v19, v19, v25
	v_cndmask_b32_e64 v25, 0, v116, s[2:3]
	v_exp_f32_e32 v19, v19
	v_add_f32_e32 v18, v18, v25
	v_exp_f32_e32 v18, v18
	v_cndmask_b32_e64 v25, 0, v117, s[0:1]
	v_ldexp_f32 v19, v19, v25
	v_cndmask_b32_e64 v25, 0, v117, s[2:3]
	v_ldexp_f32 v18, v18, v25
	v_pk_add_f32 v[18:19], v[18:19], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v24, v24
	v_rcp_f32_e32 v25, v18
	v_maximum3_f32 v29, v27, s16, s16
	v_rcp_f32_e32 v27, v19
	v_maximum3_f32 v21, v21, s16, s16
	v_maximum3_f32 v20, v20, s16, s16
	v_pk_add_f32 v[20:21], v[20:21], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v28, v28, s16, s16
	v_pk_mul_f32 v[16:17], v[16:17], v[24:25]
	v_pk_mul_f32 v[18:19], v[22:23], v[26:27]
	v_pk_mul_f32 v[16:17], v[20:21], v[16:17]
	v_pk_add_f32 v[20:21], v[28:29], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v24, 0
	v_pk_mul_f32 v[18:19], v[20:21], v[18:19]
	v_cmp_gt_i32_e64 s[0:1], s25, v34
	v_maximum3_f32 v20, |v17|, |v19|, |v19|
	v_maximum3_f32 v21, |v16|, |v18|, |v18|
	v_minimum3_f32 v4, v4, s17, s17
	v_max_u32_dpp v20, v20, v20 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v21, v21, v21 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v13, v13, s17, s17
	v_max_u32_dpp v20, v20, v20 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v21, v21, v21 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v5, v5, s17, s17
	v_max_u32_dpp v20, v20, v20 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v22, v21, v21 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v8, v8, s17, s17
	v_max_u32_dpp v21, v20, v20 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v20, v22, v22 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[20:21], v[20:21], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v9, v9, s17, s17
	v_add_u32_e32 v20, 0x7fffff, v20
	v_add_u32_e32 v21, 0x7fffff, v21
	v_lshrrev_b32_e32 v20, 23, v20
	v_lshrrev_b32_e32 v21, 23, v21
	v_min_u32_sdwa v20, v20, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v21, v21, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v23, 23, v20
	v_lshlrev_b32_e32 v22, 23, v21
	v_cvt_scalef32_pk_fp4_f32 v24, v16, v18, v23
	v_mov_b32_e32 v16, 0
	v_cvt_scalef32_pk_fp4_f32 v16, v17, v19, v22
	v_add_u32_e32 v17, s33, v34
	v_mul_lo_u32 v18, v17, s13
	v_add_u32_e32 v18, s15, v18
	v_or_b32_e32 v18, v18, v128
	v_cndmask_b32_e64 v18, v129, v18, s[0:1]
	buffer_store_byte v24, v32, s[8:11], 0 offen
	buffer_store_byte v20, v33, s[4:7], 0 offen
	buffer_store_byte v16, v18, s[8:11], 0 offen
	v_mad_u64_u32 v[16:17], s[2:3], v17, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v16, v129, v16, s[0:1]
	buffer_store_byte v21, v16, s[4:7], 0 offen
	v_or_b32_e32 v16, 0x70, v130
	v_add_u32_e32 v17, s33, v16
	v_mul_lo_u32 v18, v17, s13
	v_add_u32_e32 v18, s15, v18
	v_or_b32_e32 v18, v18, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v16
	v_mad_u64_u32 v[16:17], s[2:3], v17, 48, s[24:25]
	v_mov_b32_e32 v17, v4
	v_cndmask_b32_e64 v22, v129, v18, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v23, v129, v16, s[0:1]
	v_mov_b32_e32 v16, v12
	v_pk_mul_f32 v[16:17], v[16:17], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v20, v0, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v17
	v_cmp_gt_f32_e64 s[2:3], s18, v16
	v_minimum3_f32 v19, v1, s17, s17
	v_cndmask_b32_e64 v18, 0, v116, s[0:1]
	v_add_f32_e32 v17, v17, v18
	v_cndmask_b32_e64 v18, 0, v116, s[2:3]
	v_exp_f32_e32 v17, v17
	v_add_f32_e32 v16, v16, v18
	v_exp_f32_e32 v16, v16
	v_cndmask_b32_e64 v18, 0, v117, s[0:1]
	v_ldexp_f32 v17, v17, v18
	v_cndmask_b32_e64 v18, 0, v117, s[2:3]
	v_mov_b32_e32 v0, v13
	v_mov_b32_e32 v1, v5
	v_ldexp_f32 v16, v16, v18
	v_pk_mul_f32 v[0:1], v[0:1], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[16:17], v[16:17], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v1
	v_rcp_f32_e32 v18, v17
	v_cmp_gt_f32_e64 s[2:3], s18, v0
	v_cndmask_b32_e64 v17, 0, v116, s[0:1]
	v_add_f32_e32 v1, v1, v17
	v_cndmask_b32_e64 v17, 0, v116, s[2:3]
	v_exp_f32_e32 v1, v1
	v_add_f32_e32 v0, v0, v17
	v_exp_f32_e32 v0, v0
	v_cndmask_b32_e64 v17, 0, v117, s[0:1]
	v_ldexp_f32 v1, v1, v17
	v_cndmask_b32_e64 v17, 0, v117, s[2:3]
	v_ldexp_f32 v0, v0, v17
	v_pk_add_f32 v[0:1], v[0:1], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v16, v16
	v_rcp_f32_e32 v17, v0
	v_maximum3_f32 v21, v19, s16, s16
	v_rcp_f32_e32 v19, v1
	v_maximum3_f32 v9, v9, s16, s16
	v_maximum3_f32 v8, v8, s16, s16
	v_pk_add_f32 v[8:9], v[8:9], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v20, v20, s16, s16
	v_pk_mul_f32 v[0:1], v[12:13], v[16:17]
	v_pk_mul_f32 v[4:5], v[4:5], v[18:19]
	v_pk_mul_f32 v[0:1], v[8:9], v[0:1]
	v_pk_add_f32 v[8:9], v[20:21], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v16, 0
	v_pk_mul_f32 v[4:5], v[8:9], v[4:5]
	v_or_b32_e32 v24, 0x71, v130
	v_maximum3_f32 v8, |v1|, |v5|, |v5|
	v_maximum3_f32 v9, |v0|, |v4|, |v4|
	v_cmp_gt_i32_e64 s[0:1], s25, v24
	v_max_u32_dpp v8, v8, v8 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v9, v9, v9 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v6, v6, s17, s17
	v_max_u32_dpp v8, v8, v8 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v9, v9, v9 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v7, v7, s17, s17
	v_max_u32_dpp v8, v8, v8 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v12, v9, v9 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_or_b32_e32 v18, 0x73, v130
	v_max_u32_dpp v9, v8, v8 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v8, v12, v12 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[8:9], v[8:9], s[14:15] op_sel_hi:[1,0]
	v_mov_b32_e32 v112, 0
	v_add_u32_e32 v8, 0x7fffff, v8
	v_add_u32_e32 v9, 0x7fffff, v9
	v_lshrrev_b32_e32 v8, 23, v8
	v_lshrrev_b32_e32 v9, 23, v9
	v_min_u32_sdwa v8, v8, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v9, v9, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v13, 23, v8
	v_lshlrev_b32_e32 v12, 23, v9
	v_cvt_scalef32_pk_fp4_f32 v16, v0, v4, v13
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v5, v12
	v_add_u32_e32 v1, s33, v24
	v_mul_lo_u32 v4, v1, s13
	v_add_u32_e32 v4, s15, v4
	v_or_b32_e32 v4, v4, v128
	v_cndmask_b32_e64 v4, v129, v4, s[0:1]
	buffer_store_byte v16, v22, s[8:11], 0 offen
	buffer_store_byte v8, v23, s[4:7], 0 offen
	buffer_store_byte v0, v4, s[8:11], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v129, v0, s[0:1]
	buffer_store_byte v9, v0, s[4:7], 0 offen
	v_or_b32_e32 v0, 0x72, v130
	v_add_u32_e32 v1, s33, v0
	v_mul_lo_u32 v4, v1, s13
	v_add_u32_e32 v4, s15, v4
	v_or_b32_e32 v4, v4, v128
	v_cmp_gt_i32_e64 s[0:1], s25, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_mov_b32_e32 v9, v6
	v_cndmask_b32_e64 v16, v129, v4, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v17, v129, v0, s[0:1]
	v_minimum3_f32 v0, v14, s17, s17
	v_mov_b32_e32 v8, v0
	v_pk_mul_f32 v[8:9], v[8:9], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v4, v10, s17, s17
	v_cmp_gt_f32_e64 s[0:1], s18, v9
	v_cmp_gt_f32_e64 s[2:3], s18, v8
	v_minimum3_f32 v1, v15, s17, s17
	v_cndmask_b32_e64 v10, 0, v116, s[0:1]
	v_add_f32_e32 v9, v9, v10
	v_cndmask_b32_e64 v10, 0, v116, s[2:3]
	v_exp_f32_e32 v9, v9
	v_add_f32_e32 v8, v8, v10
	v_exp_f32_e32 v8, v8
	v_cndmask_b32_e64 v10, 0, v117, s[0:1]
	v_minimum3_f32 v5, v11, s17, s17
	v_ldexp_f32 v9, v9, v10
	v_cndmask_b32_e64 v10, 0, v117, s[2:3]
	v_minimum3_f32 v12, v2, s17, s17
	v_minimum3_f32 v11, v3, s17, s17
	v_mov_b32_e32 v2, v1
	v_mov_b32_e32 v3, v7
	v_ldexp_f32 v8, v8, v10
	v_pk_mul_f32 v[2:3], v[2:3], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[8:9], v[8:9], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s18, v3
	v_rcp_f32_e32 v10, v9
	v_cmp_gt_f32_e64 s[2:3], s18, v2
	v_cndmask_b32_e64 v9, 0, v116, s[0:1]
	v_add_f32_e32 v3, v3, v9
	v_cndmask_b32_e64 v9, 0, v116, s[2:3]
	v_exp_f32_e32 v3, v3
	v_add_f32_e32 v2, v2, v9
	v_exp_f32_e32 v2, v2
	v_cndmask_b32_e64 v9, 0, v117, s[0:1]
	v_ldexp_f32 v3, v3, v9
	v_cndmask_b32_e64 v9, 0, v117, s[2:3]
	v_ldexp_f32 v2, v2, v9
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v8, v8
	v_rcp_f32_e32 v9, v2
	v_maximum3_f32 v13, v11, s16, s16
	v_rcp_f32_e32 v11, v3
	v_maximum3_f32 v5, v5, s16, s16
	v_maximum3_f32 v4, v4, s16, s16
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v12, v12, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[8:9]
	v_pk_mul_f32 v[2:3], v[6:7], v[10:11]
	v_pk_mul_f32 v[0:1], v[4:5], v[0:1]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s25, v18
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	s_and_b64 vcc, vcc, s[0:1]
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 0
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 0
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 0
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	s_nop 0
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_add_u32_e32 v0, s33, v18
	v_cvt_scalef32_pk_fp4_f32 v112, v1, v3, v6
	v_mul_lo_u32 v1, v0, s13
	v_add_u32_e32 v1, s15, v1
	v_or_b32_e32 v1, v1, v128
	v_cndmask_b32_e64 v1, v129, v1, s[0:1]
	buffer_store_byte v8, v16, s[8:11], 0 offen
	buffer_store_byte v4, v17, s[4:7], 0 offen
	buffer_store_byte v112, v1, s[8:11], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v0, 48, s[24:25]
	v_cndmask_b32_e32 v0, v129, v0, vcc
	buffer_store_byte v5, v0, s[4:7], 0 offen
.LBB0_198:
	s_endpgm
.Lfunc_end0:
	.size	flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast, .Lfunc_end0-flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast
		.amdhsa_group_segment_fixed_size 104448
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
		.amdhsa_user_sgpr_count 8
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 1
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 1
		.amdhsa_user_sgpr_kernarg_preload_length 0
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 236
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 236
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_tg_split 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text

	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.num_vgpr, 236
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.num_agpr, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.numbered_sgpr, 48
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.num_named_barrier, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.private_seg_size, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.uses_vcc, 1
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.uses_flat_scratch, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.has_dyn_sized_stack, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.has_recursion, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           8
        .value_kind:     by_value
      - .offset:         8
        .size:           8
        .value_kind:     by_value
      - .offset:         16
        .size:           8
        .value_kind:     by_value
      - .offset:         24
        .size:           8
        .value_kind:     by_value
      - .offset:         32
        .size:           8
        .value_kind:     by_value
      - .offset:         40
        .size:           8
        .value_kind:     by_value
      - .offset:         48
        .size:           8
        .value_kind:     by_value
      - .offset:         56
        .size:           8
        .value_kind:     by_value
      - .offset:         64
        .size:           8
        .value_kind:     by_value
      - .offset:         72
        .size:           8
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         176
        .size:           8
        .value_kind:     hidden_hostcall_buffer
      - .offset:         184
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
      - .offset:         192
        .size:           8
        .value_kind:     hidden_heap_v1
      - .offset:         200
        .size:           8
        .value_kind:     hidden_default_queue
      - .offset:         208
        .size:           8
        .value_kind:     hidden_completion_action
      - .offset:         296
        .size:           8
        .value_kind:     hidden_queue_ptr
    .group_segment_fixed_size: 104448
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .max_flat_workgroup_size: 512
    .name:           flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 512
      - 1
      - 1
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef_mv1_ast.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     236
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
