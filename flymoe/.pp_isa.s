	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef
	.p2align	8
	.type	flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef,@function
flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef:
	s_load_dwordx4 s[0:3], s[4:5], 0x20
	s_mov_b32 s14, 4
	v_readfirstlane_b32 s34, v0
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
	s_lshr_b32 s33, s34, 6
	s_lshr_b32 s31, s34, 8
	s_bfe_u32 s35, s34, 0x20006
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
	buffer_load_dwordx3 v[4:6], v1, s[0:3], 0 offen
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_load_dwordx4 s[20:23], s[4:5], 0x30
	s_load_dwordx2 s[26:27], s[4:5], 0x50
	s_sub_i32 s6, s16, s17
	v_bfe_u32 v1, v0, 2, 4
	s_waitcnt lgkmcnt(0)
	s_and_b32 s1, s9, 0xffff
	s_and_b32 s21, s21, 0xffff
	s_lshl_b32 s22, s27, 2
	v_mov_b32_e32 v10, s34
	s_mov_b32 s23, s3
	s_mov_b32 s18, 0x900000
	s_mov_b32 s19, s3
	s_waitcnt vmcnt(0)
	v_readfirstlane_b32 s0, v4
	s_mul_i32 s7, s0, 0x900000
	s_mul_hi_i32 s2, s0, 0x900000
	s_add_u32 s16, s7, s12
	s_addc_u32 s2, s2, s13
	s_mul_hi_i32 s9, s0, 0x90000
	s_mul_i32 s0, s0, 0x90000
	s_and_b32 s17, s2, 0xffff
	s_add_u32 s12, s0, s14
	s_addc_u32 s7, s9, s15
	s_lshl_b32 s0, s33, 4
	v_or_b32_e32 v3, s0, v1
	s_addk_i32 s0, 0x80
	v_readfirstlane_b32 s25, v5
	v_or_b32_e32 v8, s0, v1
	v_lshlrev_b32_e32 v4, 4, v0
	v_lshlrev_b32_e32 v5, 1, v0
	s_movk_i32 s0, 0xffc0
	v_add_lshl_u32 v2, s25, v3, 2
	v_bitop3_b32 v11, v4, 48, v5 bitop3:0x48
	v_bfi_b32 v4, s0, v10, v0
	buffer_load_dword v7, v2, s[20:23], 0 offen
	v_add_lshl_u32 v1, s25, v8, 2
	v_add_lshl_u32 v5, s25, v4, 2
	buffer_load_dword v5, v5, s[20:23], 0 offen
	s_lshl_b32 s9, s6, 4
	buffer_load_dword v9, v1, s[20:23], 0 offen
	s_lshl_b32 s15, s35, 2
	v_and_b32_e32 v2, 63, v0
	v_readfirstlane_b32 s30, v6
	s_lshr_b32 s24, s34, 7
	s_or_b32 s15, s9, s15
	v_lshlrev_b32_e32 v1, 4, v2
	v_mov_b32_e32 v10, s26
	s_or_b32 s24, s24, 1
	s_mul_i32 s15, s15, 0xc000
	v_cmp_gt_i32_e32 vcc, s30, v3
	s_movk_i32 s13, 0xc00
	s_mul_i32 s14, s31, 0x18000
	s_mul_i32 s24, s24, 0xc000
	v_or_b32_e32 v6, s15, v1
	s_lshl_b32 s43, s33, 10
	s_lshl_b32 s44, s35, 12
	s_lshl_b32 s28, s31, 11
	v_add_u32_e32 v13, s14, v6
	v_add_u32_e32 v12, s24, v6
	s_mul_i32 s2, s26, 0xc00
	s_mov_b32 s0, s8
	s_add_i32 s41, s43, 0x2000
	s_add_i32 s9, s44, s28
	s_mov_b32 m0, s43
	s_add_i32 s42, s9, 0x4000
	s_add_i32 s40, s9, 0x4400
	s_mov_b32 s14, 0x90000
	s_waitcnt vmcnt(2)
	v_cndmask_b32_e32 v3, v10, v7, vcc
	v_cmp_gt_i32_e32 vcc, s30, v8
	v_mul_lo_u32 v3, v3, s13
	v_mov_b32_e32 v8, v13
	v_mov_b32_e32 v7, v12
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e32 v6, v10, v9, vcc
	v_or_b32_e32 v10, v3, v11
	v_mul_lo_u32 v3, v6, s13
	v_or_b32_e32 v9, v3, v11
	buffer_load_dwordx4 v10, s[0:3], 0 offen lds
	s_mov_b32 m0, s41
	s_and_b32 s13, s7, 0xffff
	buffer_load_dwordx4 v9, s[0:3], 0 offen lds
	s_mov_b32 m0, s42
	s_lshl_b32 s0, s6, 2
	buffer_load_dwordx4 v8, s[16:19], 0 offen lds
	s_mov_b32 m0, s40
	s_or_b32 s24, s0, s35
	buffer_load_dwordx4 v7, s[16:19], 0 offen lds
	s_mul_i32 s0, s24, 0x3000
	v_lshlrev_b32_e32 v3, 2, v2
	s_cmp_eq_u32 s31, 0
	v_or_b32_e32 v6, s0, v3
	v_accvgpr_write_b32 a54, v10
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lg_u32 s31, 0
	v_accvgpr_write_b32 a52, v6
	s_cbranch_scc1 .LBB0_3
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8000
	s_mov_b32 s15, s3
	v_accvgpr_read_b32 v6, a52
	buffer_load_dword v6, s[12:15], 0 offen lds
.LBB0_3:
	v_mov_b32_e32 v6, s26
	v_cmp_gt_i32_e32 vcc, s30, v4
	s_or_b32 s45, s9, 0x400
	s_movk_i32 s0, 0xc0
	s_and_b32 s21, s11, 0xffff
	v_cndmask_b32_e32 v4, v6, v5, vcc
	s_cmpk_lt_u32 s34, 0x100
	v_mul_lo_u32 v4, v4, s0
	s_mul_i32 s22, s26, 0xc0
	s_mov_b32 s23, 0x27000
	s_cselect_b64 s[28:29], -1, 0
	s_cmpk_gt_u32 s34, 0xff
	v_accvgpr_write_b32 a55, v4
	s_cbranch_scc1 .LBB0_5
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v4, a55
	buffer_load_dword v4, s[20:23], 0 offen lds
.LBB0_5:
	s_add_i32 s39, s41, 0x6800
	s_mov_b32 s0, s8
	s_mov_b32 m0, s39
	v_accvgpr_read_b32 v4, a54
	s_add_i32 s37, s41, 0x8800
	buffer_load_dwordx4 v4, s[0:3], 64 offen lds
	s_mov_b32 m0, s37
	s_add_i32 s36, s9, 0xc800
	buffer_load_dwordx4 v9, s[0:3], 64 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x400
	s_mov_b32 m0, s36
	s_add_i32 s38, s45, 0xc800
	buffer_load_dwordx4 v8, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_and_b64 s[46:47], s[6:7], exec
	buffer_load_dwordx4 v7, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_7
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x100
	v_accvgpr_read_b32 v4, a52
	buffer_load_dword v4, s[12:15], s0 offen lds
.LBB0_7:
	s_and_b64 s[46:47], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_9
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v4, a55
	buffer_load_dword v4, s[20:23], 4 offen lds
.LBB0_9:
	s_cmp_lg_u32 s31, 1
	s_waitcnt vmcnt(4)
	s_barrier
	s_cbranch_scc1 .LBB0_11
	s_barrier
.LBB0_11:
	s_add_i32 s34, s41, 0xf000
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x80
	s_mov_b32 m0, s34
	v_accvgpr_read_b32 v4, a54
	s_add_i32 s11, s41, 0x11000
	buffer_load_dwordx4 v4, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	s_add_i32 s9, s9, 0x15000
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x800
	s_mov_b32 m0, s9
	s_add_i32 s26, s45, 0x15000
	buffer_load_dwordx4 v8, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_and_b64 s[46:47], s[6:7], exec
	buffer_load_dwordx4 v7, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_13
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x200
	v_accvgpr_read_b32 v4, a52
	buffer_load_dword v4, s[12:15], s0 offen lds
.LBB0_13:
	s_and_b64 s[46:47], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_accvgpr_write_b32 a53, v9
	v_accvgpr_write_b32 a51, v8
	v_accvgpr_write_b32 a50, v7
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_15
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v4, a55
	buffer_load_dword v4, s[20:23], 8 offen lds
.LBB0_15:
	v_and_b32_e32 v12, 15, v0
	v_lshlrev_b32_e32 v4, 3, v0
	v_lshrrev_b32_e32 v13, 4, v2
	v_lshlrev_b32_e32 v2, 6, v12
	v_xor_b32_e32 v0, v4, v0
	v_and_or_b32 v0, v0, 48, v2
	v_lshl_or_b32 v0, s31, 13, v0
	ds_read_b128 v[4:7], v0
	ds_read_b128 v[8:11], v0 offset:1024
	ds_read_b128 v[46:49], v0 offset:2048
	ds_read_b128 v[62:65], v0 offset:3072
	ds_read_b128 v[78:81], v0 offset:4096
	ds_read_b128 v[94:97], v0 offset:5120
	ds_read_b128 v[110:113], v0 offset:6144
	v_accvgpr_write_b32 a56, v0
	ds_read_b128 a[0:3], v0 offset:7168
	v_lshlrev_b32_e32 v0, 2, v12
	s_lshl_b32 s0, s31, 9
	v_or3_b32 v0, s0, v0, v13
	v_accvgpr_write_b32 a48, v12
	ds_read_u8 v12, v0 offset:33792
	ds_read_u8 v28, v0 offset:33856
	ds_read_u8 v44, v0 offset:33920
	ds_read_u8 v60, v0 offset:33984
	ds_read_u8 v76, v0 offset:34048
	ds_read_u8 v92, v0 offset:34112
	ds_read_u8 v108, v0 offset:34176
	ds_read_u8 v124, v0 offset:34240
	v_or_b32_e32 v1, s44, v1
	ds_read_b128 v[114:117], v1 offset:16384
	ds_read_b128 v[118:121], v1 offset:17408
	ds_read_b128 a[4:7], v1 offset:18432
	ds_read_b128 a[8:11], v1 offset:19456
	s_lshl_b32 s35, s35, 8
	v_or_b32_e32 v2, s35, v3
	ds_read_b32 v125, v2 offset:32768
	v_add_u32_e32 v0, 0x8400, v0
	v_accvgpr_write_b32 a59, v0
	v_or_b32_e32 v0, 0x4000, v1
	v_accvgpr_write_b32 a58, v0
	v_or_b32_e32 v0, 0x8000, v2
	v_accvgpr_write_b32 a49, v13
	v_accvgpr_write_b32 a57, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[4:7], v[114:117], 0, v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[4:7], v[118:121], 0, v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[4:7], a[4:7], 0, v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[4:7], a[8:11], 0, v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], v[8:11], v[114:117], 0, v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[8:11], v[118:121], 0, v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[8:11], a[4:7], 0, v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], v[8:11], a[8:11], 0, v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], v[46:49], v[114:117], 0, v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], v[46:49], v[118:121], 0, v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], v[46:49], a[4:7], 0, v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], v[46:49], a[8:11], 0, v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], v[62:65], v[114:117], 0, v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], v[62:65], v[118:121], 0, v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], v[62:65], a[4:7], 0, v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], v[62:65], a[8:11], 0, v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], v[78:81], v[114:117], 0, v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], v[78:81], v[118:121], 0, v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], v[78:81], a[4:7], 0, v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], v[78:81], a[8:11], 0, v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], v[94:97], v[114:117], 0, v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], v[94:97], v[118:121], 0, v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], v[94:97], a[4:7], 0, v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], v[94:97], a[8:11], 0, v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], v[110:113], v[114:117], 0, v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], v[110:113], v[118:121], 0, v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], v[110:113], a[4:7], 0, v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[110:113], a[8:11], 0, v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[0:3], v[114:117], 0, v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[0:3], v[118:121], 0, v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[0:3], a[4:7], 0, v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[0:3], a[8:11], 0, v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xc0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0xc00
	s_mov_b32 m0, s42
	v_accvgpr_read_b32 v1, a51
	buffer_load_dwordx4 v1, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	v_accvgpr_read_b32 v2, a50
	buffer_load_dwordx4 v2, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_17
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x300
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_17:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v14, v1
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_19
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 12 offen lds
.LBB0_19:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[76:79], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[4:7], a[44:47], a[80:83], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[8:11], a[44:47], a[84:87], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[12:15], a[44:47], a[88:91], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[44:47], a[92:95], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[20:23], a[44:47], a[96:99], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x100
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x1000
	s_mov_b32 m0, s36
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_21
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x400
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_21:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_23
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 16 offen lds
.LBB0_23:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x140
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x1400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_25
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x500
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_25:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_27
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 20 offen lds
.LBB0_27:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x180
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x1800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_29
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x600
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_29:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_31
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 24 offen lds
.LBB0_31:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x1c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x1c00
	s_mov_b32 m0, s36
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_33
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x700
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_33:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_35
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 28 offen lds
.LBB0_35:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x200
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x2000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_37
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x800
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_37:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_39
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 32 offen lds
.LBB0_39:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x240
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x2400
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_41
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x900
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_41:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_43
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 36 offen lds
.LBB0_43:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x280
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x2800
	s_mov_b32 m0, s36
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_45
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xa00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_45:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_47
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 40 offen lds
.LBB0_47:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x2c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x2c00
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_49
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xb00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_49:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_51
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 44 offen lds
.LBB0_51:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x300
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x3000
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_53
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xc00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_53:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_55
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 48 offen lds
.LBB0_55:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x340
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x3400
	s_mov_b32 m0, s36
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_57
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xd00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_57:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_59
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 52 offen lds
.LBB0_59:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x380
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x3800
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_61
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xe00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_61:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_63
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 56 offen lds
.LBB0_63:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x3c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x3c00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_65
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0xf00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_65:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_67
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 60 offen lds
.LBB0_67:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x400
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4000
	s_mov_b32 m0, s36
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_69
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1000
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_69:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_71
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], 64 offen lds
.LBB0_71:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[76:79], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[100:103], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x440
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x4400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_73
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1100
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_73:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_75
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x44
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_75:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x480
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_77
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1200
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_77:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v10
	v_mov_b32_e32 v14, v11
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_79
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x48
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_79:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x4c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x4c00
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_81
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1300
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_81:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_83
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x4c
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_83:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x500
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x5000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_85
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1400
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_85:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_87
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x50
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_87:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x540
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x5400
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_89
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1500
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_89:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_91
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x54
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_91:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x580
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x5800
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_93
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1600
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_93:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_95
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x58
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_95:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x5c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x5c00
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_97
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1700
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_97:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_99
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x5c
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_99:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x600
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6000
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_101
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1800
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_101:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_103
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x60
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_103:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x640
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6400
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_105
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1900
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_105:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_107
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x64
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_107:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x680
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x6800
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_109
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1a00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_109:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_111
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x68
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_111:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x6c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x6c00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_113
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1b00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_113:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_115
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x6c
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_115:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x700
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7000
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_117
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1c00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_117:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_119
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x70
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_119:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x740
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_movk_i32 s0, 0x7400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_121
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1d00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_121:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_123
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x74
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_123:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x780
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_125
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1e00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_125:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_127
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x78
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_127:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x7c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_movk_i32 s0, 0x7c00
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_129
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x1f00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_129:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_131
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x7c
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_131:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x800
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_mov_b32 s0, 0x8000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_133
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2000
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_133:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_135
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x80
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_135:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x840
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x8400
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_137
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2100
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_137:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_139
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x84
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_139:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x880
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x8800
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_141
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2200
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_141:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_143
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x88
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_143:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x8c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_mov_b32 s0, 0x8c00
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_145
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2300
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_145:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_147
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x8c
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_147:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x900
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9000
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_149
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2400
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_149:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_151
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x90
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_151:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x940
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9400
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_153
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2500
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_153:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_155
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x94
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_155:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x980
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_mov_b32 s0, 0x9800
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_157
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2600
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_157:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_159
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x98
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_159:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0x9c0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0x9c00
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_161
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2700
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_161:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_163
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0x9c
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_163:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xa00
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xa000
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_165
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2800
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_165:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_167
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xa0
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_167:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a96
	v_accvgpr_read_b32 v1, a97
	v_accvgpr_read_b32 v2, a98
	v_accvgpr_read_b32 v3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[12:15], a[36:39], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[16:19], a[36:39], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xa40
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_mov_b32 s0, 0xa400
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_169
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2900
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_169:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_171
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xa4
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_171:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[24:27], a[44:47], a[120:123], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xa80
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xa800
	s_mov_b32 m0, s42
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_173
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2a00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_173:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_175
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xa8
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_175:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[4:7], a[32:35], a[96:99], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v13
	v_accvgpr_write_b32 a86, v12
	v_accvgpr_write_b32 a85, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a84, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a95, v3
	v_accvgpr_write_b32 a94, v2
	v_accvgpr_write_b32 a93, v1
	v_accvgpr_write_b32 a92, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[20:23], a[44:47], v[92:95], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[116:119], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[100:103], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[24:27], a[44:47], a[124:127], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_accvgpr_write_b32 a43, v3
	v_accvgpr_write_b32 a42, v2
	v_accvgpr_write_b32 a41, v1
	v_accvgpr_write_b32 a40, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xac0
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xac00
	s_mov_b32 m0, s36
	v_mov_b32_e32 v11, v15
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	v_mov_b32_e32 v10, v14
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_and_b64 s[44:45], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_177
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2b00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_177:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_179
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xac
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_179:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 v[2:5], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 v[6:9], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[36:39], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_mov_b32 a44, a60
	v_accvgpr_mov_b32 a45, a61
	v_accvgpr_mov_b32 a46, a62
	v_accvgpr_mov_b32 a47, a63
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], v[2:5], a[24:27], a[44:47], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a64
	v_accvgpr_mov_b32 a45, a65
	v_accvgpr_mov_b32 a46, a66
	v_accvgpr_mov_b32 a47, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], v[6:9], a[28:31], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], v[2:5], a[28:31], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a68
	v_accvgpr_mov_b32 a45, a69
	v_accvgpr_mov_b32 a46, a70
	v_accvgpr_mov_b32 a47, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], v[6:9], a[32:35], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], v[2:5], a[32:35], a[44:47], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a44, a72
	v_accvgpr_mov_b32 a45, a73
	v_accvgpr_mov_b32 a46, a74
	v_accvgpr_mov_b32 a47, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[0:3], a[24:27], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], v[2:5], a[36:39], a[44:47], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	s_nop 0
	v_accvgpr_mov_b32 a44, a76
	v_accvgpr_mov_b32 a45, a77
	v_accvgpr_mov_b32 a46, a78
	v_accvgpr_mov_b32 a47, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[0:3], a[28:31], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], v[6:9], a[24:27], a[44:47], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], v[6:9], a[36:39], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[0:3], a[32:35], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[0:3], a[36:39], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a96
	v_accvgpr_mov_b32 a1, a97
	v_accvgpr_mov_b32 a2, a98
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[4:7], a[24:27], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[4:7], a[28:31], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[4:7], a[32:35], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[4:7], a[36:39], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a92
	v_accvgpr_read_b32 v1, a93
	v_accvgpr_read_b32 v2, a94
	v_accvgpr_read_b32 v3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[8:11], a[24:27], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[8:11], a[28:31], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[8:11], a[32:35], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[8:11], a[36:39], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a100
	v_accvgpr_read_b32 v1, a101
	v_accvgpr_read_b32 v2, a102
	v_accvgpr_read_b32 v3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[16:19], a[24:27], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[16:19], a[28:31], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[16:19], a[32:35], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], a[16:19], a[36:39], v[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a40
	v_accvgpr_read_b32 v1, a41
	v_accvgpr_read_b32 v2, a42
	v_accvgpr_read_b32 v3, a43
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[12:15], a[24:27], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[12:15], a[28:31], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[12:15], a[32:35], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[12:15], a[36:39], a[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[24:27], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[20:23], a[28:31], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[20:23], a[32:35], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[20:23], a[36:39], v[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xb00
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v9, a53
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s19, s3
	s_mov_b32 s0, 0xb000
	s_mov_b32 m0, s9
	s_and_b64 s[44:45], s[6:7], exec
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_181
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2c00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_181:
	s_and_b64 s[44:45], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_183
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xb0
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_183:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0
	ds_read_b128 a[4:7], v0 offset:1024
	ds_read_b128 a[8:11], v0 offset:2048
	ds_read_b128 a[12:15], v0 offset:3072
	ds_read_b128 a[16:19], v0 offset:4096
	ds_read_b128 a[20:23], v0 offset:5120
	ds_read_b128 a[24:27], v0 offset:6144
	ds_read_b128 a[28:31], v0 offset:7168
	ds_read_u8 v0, v7
	ds_read_u8 v1, v7 offset:64
	ds_read_u8 v2, v7 offset:128
	ds_read_u8 v3, v7 offset:192
	ds_read_u8 v4, v7 offset:256
	ds_read_u8 v5, v7 offset:320
	ds_read_u8 v6, v7 offset:384
	ds_read_u8 v7, v7 offset:448
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8
	ds_read_b128 a[36:39], v8 offset:1024
	ds_read_b128 a[40:43], v8 offset:2048
	ds_read_b128 a[44:47], v8 offset:3072
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[4:7], a[32:35], a[124:127], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[20:23], a[44:47], a[96:99], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[24:27], a[32:35], a[92:95], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[24:27], a[36:39], a[88:91], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], a[24:27], a[44:47], v[108:111], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[32:35], a[84:87], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[28:31], a[36:39], a[76:79], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[80:83], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s43
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xb40
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s41
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xb400
	s_mov_b32 m0, s42
	s_nop 0
	buffer_load_dwordx4 v11, s[16:19], s0 offen lds
	s_mov_b32 m0, s40
	s_and_b64 s[40:41], s[6:7], exec
	buffer_load_dwordx4 v10, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_185
	s_add_i32 m0, s35, 0x8000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2d00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_185:
	s_and_b64 s[40:41], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v14, v10
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_187
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x8400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xb4
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_187:
	v_accvgpr_read_b32 v0, a56
	v_accvgpr_read_b32 v7, a59
	ds_read_b128 a[0:3], v0 offset:34816
	ds_read_b128 a[4:7], v0 offset:35840
	ds_read_b128 a[8:11], v0 offset:36864
	ds_read_b128 a[12:15], v0 offset:37888
	ds_read_b128 a[16:19], v0 offset:38912
	ds_read_b128 a[20:23], v0 offset:39936
	ds_read_b128 a[24:27], v0 offset:40960
	ds_read_b128 a[28:31], v0 offset:41984
	ds_read_u8 v0, v7 offset:34816
	ds_read_u8 v1, v7 offset:34880
	ds_read_u8 v2, v7 offset:34944
	ds_read_u8 v3, v7 offset:35008
	ds_read_u8 v4, v7 offset:35072
	ds_read_u8 v5, v7 offset:35136
	ds_read_u8 v6, v7 offset:35200
	ds_read_u8 v7, v7 offset:35264
	v_accvgpr_read_b32 v8, a58
	ds_read_b128 a[32:35], v8 offset:34816
	ds_read_b128 a[36:39], v8 offset:35840
	ds_read_b128 a[40:43], v8 offset:36864
	ds_read_b128 a[44:47], v8 offset:37888
	v_accvgpr_read_b32 v8, a57
	ds_read_b32 v8, v8 offset:34816
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[4:7], a[44:47], v[28:31], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[32:35], a[60:63], v0, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[36:39], a[64:67], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a79, v13
	v_accvgpr_write_b32 a78, v12
	v_accvgpr_write_b32 a77, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[0:3], a[40:43], a[68:71], v0, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a76, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[0:3], a[44:47], a[72:75], v0, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[4:7], a[32:35], a[116:119], v1, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v1, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v1, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v2, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v2, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[10:13], a[8:11], a[44:47], v[44:47], v2, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v3, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a83, v13
	v_accvgpr_write_b32 a82, v12
	v_accvgpr_write_b32 a81, v11
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v3, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a80, v10
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[12:15], a[44:47], v[60:63], v3, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[96:99], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a87, v3
	v_accvgpr_write_b32 a86, v2
	v_accvgpr_write_b32 a85, v1
	v_accvgpr_write_b32 a84, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[16:19], a[44:47], v[76:79], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a91, v3
	v_accvgpr_write_b32 a90, v2
	v_accvgpr_write_b32 a89, v1
	v_accvgpr_write_b32 a88, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[24:27], a[44:47], v[108:111], v6, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 5
	v_accvgpr_write_b32 a99, v3
	v_accvgpr_write_b32 a98, v2
	v_accvgpr_write_b32 a97, v1
	v_accvgpr_write_b32 a96, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[28:31], a[44:47], v[124:127], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[20:23], a[44:47], a[120:123], v5, v8 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[112:115], v6, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v6, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[104:107], v7, v8 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[100:103], v7, v8 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v7, v8 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 1
	v_accvgpr_write_b32 a103, v3
	v_accvgpr_write_b32 a102, v2
	v_accvgpr_write_b32 a101, v1
	v_accvgpr_write_b32 a100, v0
	s_setprio 0
	s_mov_b32 m0, s39
	s_mov_b32 s0, s8
	s_movk_i32 s15, 0xb80
	v_accvgpr_read_b32 v0, a54
	s_barrier
	buffer_load_dwordx4 v0, s[0:3], s15 offen lds
	s_mov_b32 m0, s37
	s_mov_b32 s19, s3
	buffer_load_dwordx4 v9, s[0:3], s15 offen lds
	s_mov_b32 s0, 0xb800
	s_mov_b32 m0, s36
	s_and_b64 s[36:37], s[6:7], exec
	buffer_load_dwordx4 v15, s[16:19], s0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v14, s[16:19], s0 offen lds
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_189
	s_add_i32 m0, s35, 0x10800
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2e00
	v_accvgpr_read_b32 v0, a52
	buffer_load_dword v0, s[12:15], s0 offen lds
.LBB0_189:
	s_and_b64 s[36:37], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_191
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x10c00
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xb8
	v_accvgpr_read_b32 v0, a55
	buffer_load_dword v0, s[20:23], s0 offen lds
.LBB0_191:
	v_accvgpr_read_b32 v1, a56
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12000, v1
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12400, v1
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x12800, v1
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x12c00, v1
	v_accvgpr_read_b32 v1, a59
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_u8 v12, v0
	v_add_u32_e32 v0, 0x11040, v1
	ds_read_u8 v28, v0
	v_add_u32_e32 v0, 0x11080, v1
	ds_read_u8 v44, v0
	v_add_u32_e32 v0, 0x110c0, v1
	ds_read_u8 v60, v0
	v_add_u32_e32 v0, 0x11100, v1
	ds_read_u8 v76, v0
	v_add_u32_e32 v0, 0x11140, v1
	ds_read_u8 v92, v0
	v_add_u32_e32 v0, 0x11180, v1
	ds_read_u8 v108, v0
	v_add_u32_e32 v0, 0x111c0, v1
	v_accvgpr_read_b32 v1, a58
	ds_read_u8 v124, v0
	v_add_u32_e32 v0, 0x11000, v1
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11400, v1
	ds_read_b128 a[36:39], v0
	v_add_u32_e32 v0, 0x11800, v1
	ds_read_b128 a[40:43], v0
	v_add_u32_e32 v0, 0x11c00, v1
	ds_read_b128 a[44:47], v0
	v_accvgpr_read_b32 v0, a57
	v_add_u32_e32 v0, 0x11000, v0
	ds_read_b32 v125, v0
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_read_b32 v0, a60
	v_accvgpr_read_b32 v1, a61
	v_accvgpr_read_b32 v2, a62
	v_accvgpr_read_b32 v3, a63
	v_accvgpr_read_b32 v4, a64
	v_accvgpr_read_b32 v5, a65
	v_accvgpr_read_b32 v6, a66
	v_accvgpr_read_b32 v7, a67
	v_accvgpr_mov_b32 a60, a68
	v_accvgpr_mov_b32 a61, a69
	v_accvgpr_mov_b32 a62, a70
	v_accvgpr_mov_b32 a63, a71
	v_accvgpr_mov_b32 a64, a72
	v_accvgpr_mov_b32 a65, a73
	v_accvgpr_mov_b32 a66, a74
	v_accvgpr_mov_b32 a67, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[0:3], a[32:35], v[0:3], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[4:7], a[0:3], a[36:39], v[4:7], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[60:63], a[0:3], a[40:43], a[60:63], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[64:67], a[0:3], a[44:47], a[64:67], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a76
	v_accvgpr_mov_b32 a1, a77
	v_accvgpr_mov_b32 a2, a78
	v_accvgpr_mov_b32 a3, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 a[124:127], a[4:7], a[32:35], a[124:127], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[68:71], a[4:7], a[44:47], a[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a0, a80
	v_accvgpr_mov_b32 a1, a81
	v_accvgpr_mov_b32 a2, a82
	v_accvgpr_mov_b32 a3, a83
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[72:75], a[8:11], a[44:47], a[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a0, a84
	v_accvgpr_mov_b32 a1, a85
	v_accvgpr_mov_b32 a2, a86
	v_accvgpr_mov_b32 a3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[76:79], a[12:15], a[44:47], a[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a0, a88
	v_accvgpr_mov_b32 a1, a89
	v_accvgpr_mov_b32 a2, a90
	v_accvgpr_mov_b32 a3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[80:83], a[16:19], a[44:47], a[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a0, a92
	v_accvgpr_mov_b32 a1, a93
	v_accvgpr_mov_b32 a2, a94
	v_accvgpr_mov_b32 a3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[84:87], a[20:23], a[44:47], a[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a0, a96
	v_accvgpr_mov_b32 a1, a97
	v_accvgpr_mov_b32 a2, a98
	v_accvgpr_mov_b32 a3, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 a[88:91], a[24:27], a[44:47], a[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_mov_b32 a0, a100
	v_accvgpr_mov_b32 a1, a101
	v_accvgpr_mov_b32 a2, a102
	v_accvgpr_mov_b32 a3, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[116:119], a[24:27], a[36:39], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[112:115], a[28:31], a[32:35], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[36:39], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[108:111], a[28:31], a[40:43], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[92:95], a[28:31], a[44:47], a[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_mov_b32 m0, s34
	s_mov_b32 s0, s8
	s_movk_i32 s8, 0xbc0
	v_accvgpr_read_b32 v12, a54
	s_barrier
	buffer_load_dwordx4 v12, s[0:3], s8 offen lds
	s_mov_b32 m0, s11
	v_accvgpr_read_b32 v12, a53
	buffer_load_dwordx4 v12, s[0:3], s8 offen lds
	s_mov_b32 s19, s3
	s_mov_b32 s0, 0xbc00
	s_mov_b32 m0, s9
	v_accvgpr_read_b32 v12, a51
	buffer_load_dwordx4 v12, s[16:19], s0 offen lds
	s_mov_b32 m0, s26
	v_accvgpr_read_b32 v12, a50
	buffer_load_dwordx4 v12, s[16:19], s0 offen lds
	s_and_b64 s[0:1], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_193
	s_add_i32 m0, s35, 0x19000
	s_mov_b32 s15, s3
	s_movk_i32 s0, 0x2f00
	v_accvgpr_read_b32 v12, a52
	buffer_load_dword v12, s[12:15], s0 offen lds
.LBB0_193:
	s_and_b64 s[0:1], s[28:29], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_195
	s_lshl_b32 s0, s33, 8
	s_add_i32 m0, s0, 0x19400
	s_mov_b32 s20, s10
	s_movk_i32 s0, 0xbc
	v_accvgpr_read_b32 v12, a55
	buffer_load_dword v12, s[20:23], s0 offen lds
.LBB0_195:
	v_accvgpr_read_b32 v9, a56
	v_accvgpr_read_b32 v15, a59
	ds_read_b128 a[0:3], v9
	ds_read_b128 a[4:7], v9 offset:1024
	ds_read_b128 a[8:11], v9 offset:2048
	ds_read_b128 a[12:15], v9 offset:3072
	ds_read_b128 a[16:19], v9 offset:4096
	ds_read_b128 a[20:23], v9 offset:5120
	ds_read_b128 a[24:27], v9 offset:6144
	ds_read_b128 a[28:31], v9 offset:7168
	ds_read_u8 v12, v15
	ds_read_u8 v28, v15 offset:64
	ds_read_u8 v44, v15 offset:128
	ds_read_u8 v60, v15 offset:192
	ds_read_u8 v76, v15 offset:256
	ds_read_u8 v92, v15 offset:320
	ds_read_u8 v108, v15 offset:384
	ds_read_u8 v124, v15 offset:448
	v_accvgpr_read_b32 v14, a58
	ds_read_b128 a[32:35], v14
	ds_read_b128 a[36:39], v14 offset:1024
	ds_read_b128 a[40:43], v14 offset:2048
	ds_read_b128 a[44:47], v14 offset:3072
	v_accvgpr_read_b32 v13, a57
	ds_read_b32 v125, v13
	s_waitcnt vmcnt(4) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[0:3], a[32:35], v[0:3], v12, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a58, a60
	v_accvgpr_mov_b32 a59, a61
	v_accvgpr_mov_b32 a60, a62
	v_mfma_scale_f32_16x16x128_f8f6f4 a[100:103], a[4:7], a[32:35], a[124:127], v28, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a61, a63
	v_accvgpr_mov_b32 a62, a64
	v_accvgpr_mov_b32 a63, a65
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_write_b32 a53, v3
	v_accvgpr_write_b32 a52, v2
	v_accvgpr_write_b32 a51, v1
	v_accvgpr_write_b32 a50, v0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[0:3], a[0:3], a[36:39], v[4:7], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a64, a66
	v_accvgpr_mov_b32 a65, a67
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v28, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v44, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 3
	v_accvgpr_write_b32 a57, v3
	v_accvgpr_write_b32 a56, v2
	v_accvgpr_write_b32 a55, v1
	v_accvgpr_write_b32 a54, v0
	v_accvgpr_read_b32 v0, a68
	v_accvgpr_read_b32 v1, a69
	v_accvgpr_read_b32 v2, a70
	v_accvgpr_read_b32 v3, a71
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[0:3], v28, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a72
	v_accvgpr_read_b32 v1, a73
	v_accvgpr_read_b32 v2, a74
	v_accvgpr_read_b32 v3, a75
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v44, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 0
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[0:3], v44, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a76
	v_accvgpr_read_b32 v1, a77
	v_accvgpr_read_b32 v2, a78
	v_accvgpr_read_b32 v3, a79
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v60, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v60, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[0:3], v60, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a80
	v_accvgpr_read_b32 v1, a81
	v_accvgpr_read_b32 v2, a82
	v_accvgpr_read_b32 v3, a83
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v76, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v76, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[0:3], v76, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a84
	v_accvgpr_read_b32 v1, a85
	v_accvgpr_read_b32 v2, a86
	v_accvgpr_read_b32 v3, a87
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v92, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v92, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[0:3], v92, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_nop 2
	v_accvgpr_read_b32 v0, a88
	v_accvgpr_read_b32 v1, a89
	v_accvgpr_read_b32 v2, a90
	v_accvgpr_read_b32 v3, a91
	v_mfma_scale_f32_16x16x128_f8f6f4 a[58:61], a[0:3], a[40:43], a[58:61], v12, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[120:123], a[24:27], a[32:35], a[120:123], v108, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[82:85], a[24:27], a[36:39], a[116:119], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v108, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], a[24:27], a[44:47], v[0:3], v108, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[96:99], a[0:3], a[44:47], a[62:65], v12, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a92
	v_accvgpr_mov_b32 a1, a93
	v_accvgpr_mov_b32 a2, a94
	v_accvgpr_mov_b32 a3, a95
	v_mfma_scale_f32_16x16x128_f8f6f4 a[74:77], a[28:31], a[32:35], a[112:115], v124, v125 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[70:73], a[28:31], a[36:39], a[104:107], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[78:81], a[28:31], a[40:43], a[108:111], v124, v125 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[104:107], a[28:31], a[44:47], a[0:3], v124, v125 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_barrier
	s_nop 0
	ds_read_b128 a[0:3], v9 offset:34816
	ds_read_b128 a[4:7], v9 offset:35840
	ds_read_b128 a[8:11], v9 offset:36864
	ds_read_b128 a[12:15], v9 offset:37888
	ds_read_b128 a[16:19], v9 offset:38912
	ds_read_b128 a[20:23], v9 offset:39936
	ds_read_b128 a[24:27], v9 offset:40960
	ds_read_b128 a[28:31], v9 offset:41984
	ds_read_u8 v1, v15 offset:34816
	ds_read_u8 v2, v15 offset:34880
	ds_read_u8 v3, v15 offset:34944
	ds_read_u8 v4, v15 offset:35008
	ds_read_u8 v5, v15 offset:35072
	ds_read_u8 v6, v15 offset:35136
	ds_read_u8 v7, v15 offset:35200
	ds_read_u8 v8, v15 offset:35264
	ds_read_b128 a[32:35], v14 offset:34816
	ds_read_b128 a[36:39], v14 offset:35840
	ds_read_b128 a[40:43], v14 offset:36864
	ds_read_b128 a[44:47], v14 offset:37888
	ds_read_b32 v0, v13 offset:34816
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_read_b32 v16, a100
	v_accvgpr_read_b32 v17, a101
	v_accvgpr_read_b32 v18, a102
	v_accvgpr_read_b32 v19, a103
	v_mfma_scale_f32_16x16x128_f8f6f4 a[50:53], a[0:3], a[32:35], a[50:53], v1, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a65, a61
	v_accvgpr_mov_b32 a64, a60
	v_accvgpr_mov_b32 a63, a59
	v_mfma_scale_f32_16x16x128_f8f6f4 a[54:57], a[0:3], a[36:39], a[54:57], v1, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a62, a58
	v_accvgpr_mov_b32 a66, a96
	v_accvgpr_mov_b32 a67, a97
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], a[4:7], a[32:35], v[16:19], v2, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a68, a98
	v_accvgpr_mov_b32 a69, a99
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v2, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v2, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v2, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v3, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v3, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v3, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v3, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v4, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v4, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v4, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v4, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v5, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v5, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v5, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v5, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v6, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v6, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v6, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v6, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[104:107], a[24:27], a[40:43], v[104:107], v7, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[108:111], a[24:27], a[44:47], v[108:111], v7, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[62:65], a[0:3], a[40:43], a[62:65], v1, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[66:69], a[0:3], a[44:47], a[66:69], v1, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[90:93], a[24:27], a[32:35], a[120:123], v7, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[86:89], a[24:27], a[36:39], a[82:85], v7, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[82:85], a[28:31], a[32:35], a[74:77], v8, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[74:77], a[28:31], a[36:39], a[70:73], v8, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[78:81], a[28:31], a[40:43], a[78:81], v8, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[70:73], a[28:31], a[44:47], a[104:107], v8, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	v_add_u32_e32 v0, 0x11000, v9
	s_barrier
	ds_read_b128 a[0:3], v0
	v_add_u32_e32 v0, 0x11400, v9
	ds_read_b128 a[4:7], v0
	v_add_u32_e32 v0, 0x11800, v9
	ds_read_b128 a[8:11], v0
	v_add_u32_e32 v0, 0x11c00, v9
	ds_read_b128 a[12:15], v0
	v_add_u32_e32 v0, 0x12000, v9
	ds_read_b128 a[16:19], v0
	v_add_u32_e32 v0, 0x12400, v9
	ds_read_b128 a[20:23], v0
	v_add_u32_e32 v0, 0x12800, v9
	ds_read_b128 a[24:27], v0
	v_add_u32_e32 v0, 0x12c00, v9
	ds_read_b128 a[28:31], v0
	v_add_u32_e32 v0, 0x11000, v15
	ds_read_u8 v8, v0
	v_add_u32_e32 v0, 0x11040, v15
	ds_read_u8 v9, v0
	v_add_u32_e32 v0, 0x11080, v15
	ds_read_u8 v10, v0
	v_add_u32_e32 v0, 0x110c0, v15
	ds_read_u8 v11, v0
	v_add_u32_e32 v0, 0x11100, v15
	ds_read_u8 v4, v0
	v_add_u32_e32 v0, 0x11140, v15
	ds_read_u8 v5, v0
	v_add_u32_e32 v0, 0x11180, v15
	ds_read_u8 v6, v0
	v_add_u32_e32 v0, 0x111c0, v15
	ds_read_u8 v7, v0
	v_add_u32_e32 v0, 0x11000, v14
	ds_read_b128 a[32:35], v0
	v_add_u32_e32 v0, 0x11400, v14
	ds_read_b128 a[36:39], v0
	v_add_u32_e32 v0, 0x11800, v14
	ds_read_b128 a[40:43], v0
	v_add_u32_e32 v0, 0x11c00, v14
	ds_read_b128 a[44:47], v0
	v_add_u32_e32 v0, 0x11000, v13
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_accvgpr_read_b32 v12, a50
	v_accvgpr_read_b32 v13, a51
	v_accvgpr_read_b32 v14, a52
	v_accvgpr_read_b32 v15, a53
	v_accvgpr_mov_b32 a61, a57
	v_accvgpr_mov_b32 a60, a56
	v_accvgpr_mov_b32 a59, a55
	v_accvgpr_mov_b32 a58, a54
	v_accvgpr_mov_b32 a54, a62
	v_accvgpr_mov_b32 a55, a63
	v_accvgpr_mov_b32 a56, a64
	v_accvgpr_mov_b32 a57, a65
	v_accvgpr_mov_b32 a50, a66
	v_accvgpr_mov_b32 a51, a67
	v_accvgpr_mov_b32 a52, a68
	v_accvgpr_mov_b32 a53, a69
	v_mfma_scale_f32_16x16x128_f8f6f4 v[124:127], a[0:3], a[32:35], v[12:15], v8, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[58:61], a[0:3], a[36:39], a[58:61], v8, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[54:57], a[0:3], a[40:43], a[54:57], v8, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[50:53], a[0:3], a[44:47], a[50:53], v8, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_accvgpr_mov_b32 a0, a70
	v_accvgpr_mov_b32 a1, a71
	v_accvgpr_mov_b32 a2, a72
	v_accvgpr_mov_b32 a3, a73
	v_mfma_scale_f32_16x16x128_f8f6f4 v[16:19], a[4:7], a[32:35], v[16:19], v9, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[20:23], a[4:7], a[36:39], v[20:23], v9, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[24:27], a[4:7], a[40:43], v[24:27], v9, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[28:31], a[4:7], a[44:47], v[28:31], v9, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[32:35], a[8:11], a[32:35], v[32:35], v10, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[36:39], a[8:11], a[36:39], v[36:39], v10, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[40:43], a[8:11], a[40:43], v[40:43], v10, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[44:47], a[8:11], a[44:47], v[44:47], v10, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[48:51], a[12:15], a[32:35], v[48:51], v11, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[52:55], a[12:15], a[36:39], v[52:55], v11, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[56:59], a[12:15], a[40:43], v[56:59], v11, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[60:63], a[12:15], a[44:47], v[60:63], v11, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[64:67], a[16:19], a[32:35], v[64:67], v4, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[68:71], a[16:19], a[36:39], v[68:71], v4, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[72:75], a[16:19], a[40:43], v[72:75], v4, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[76:79], a[16:19], a[44:47], v[76:79], v4, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[80:83], a[20:23], a[32:35], v[80:83], v5, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[84:87], a[20:23], a[36:39], v[84:87], v5, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[88:91], a[20:23], a[40:43], v[88:91], v5, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[92:95], a[20:23], a[44:47], v[92:95], v5, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[20:23], a[24:27], a[32:35], a[90:93], v6, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[16:19], a[24:27], a[36:39], a[86:89], v6, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[102:105], a[24:27], a[40:43], v[104:107], v6, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 v[106:109], a[24:27], a[44:47], v[108:111], v6, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[12:15], a[28:31], a[32:35], a[82:85], v7, v0 op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[4:7], a[28:31], a[36:39], a[74:77], v7, v0 op_sel:[0,1,0] op_sel_hi:[0,0,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[8:11], a[28:31], a[40:43], a[78:81], v7, v0 op_sel_hi:[0,1,0] cbsz:4 blgp:4
	v_mfma_scale_f32_16x16x128_f8f6f4 a[0:3], a[28:31], a[44:47], a[0:3], v7, v0 op_sel:[0,1,0] op_sel_hi:[0,1,0] cbsz:4 blgp:4
	s_setprio 0
	s_and_b64 s[0:1], s[6:7], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_barrier
	s_cbranch_scc1 .LBB0_197
	s_barrier
.LBB0_197:
	s_mov_b32 s13, 0x40e00000
	v_accvgpr_read_b32 v12, a58
	v_minimum3_f32 v96, v124, s13, s13
	v_minimum3_f32 v0, v12, s13, s13
	v_mov_b32_e32 v98, v96
	v_mov_b32_e32 v99, v0
	s_mov_b32 s12, 0xc01d265f
	v_pk_mul_f32 v[98:99], v[98:99], s[12:13] op_sel_hi:[1,0]
	s_mov_b32 s15, 0xc2fc0000
	v_mov_b32_e32 v120, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v99
	v_cmp_gt_f32_e64 s[0:1], s15, v98
	v_not_b32_e32 v124, 63
	v_cndmask_b32_e32 v1, 0, v120, vcc
	v_add_f32_e32 v1, v99, v1
	v_cndmask_b32_e64 v2, 0, v120, s[0:1]
	v_add_f32_e32 v2, v98, v2
	v_exp_f32_e32 v1, v1
	v_exp_f32_e32 v2, v2
	v_cndmask_b32_e32 v3, 0, v124, vcc
	v_accvgpr_read_b32 v13, a59
	v_ldexp_f32 v99, v1, v3
	v_cndmask_b32_e64 v1, 0, v124, s[0:1]
	v_ldexp_f32 v98, v2, v1
	v_minimum3_f32 v97, v125, s13, s13
	v_minimum3_f32 v1, v13, s13, s13
	v_mov_b32_e32 v100, v97
	v_mov_b32_e32 v101, v1
	v_pk_mul_f32 v[100:101], v[100:101], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[98:99], v[98:99], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e32 vcc, s15, v101
	v_cmp_gt_f32_e64 s[0:1], s15, v100
	v_rcp_f32_e32 v110, v98
	v_cndmask_b32_e32 v2, 0, v120, vcc
	v_add_f32_e32 v2, v101, v2
	v_cndmask_b32_e64 v3, 0, v120, s[0:1]
	v_add_f32_e32 v3, v100, v3
	v_exp_f32_e32 v2, v2
	v_exp_f32_e32 v3, v3
	v_cndmask_b32_e32 v4, 0, v124, vcc
	v_rcp_f32_e32 v98, v99
	v_ldexp_f32 v101, v2, v4
	v_cndmask_b32_e64 v2, 0, v124, s[0:1]
	v_ldexp_f32 v100, v3, v2
	v_pk_add_f32 v[100:101], v[100:101], 1.0 op_sel_hi:[1,0]
	v_accvgpr_read_b32 v4, a54
	v_rcp_f32_e32 v111, v100
	v_rcp_f32_e32 v99, v101
	v_accvgpr_read_b32 v5, a55
	s_mov_b32 s16, 0xc0e00000
	v_minimum3_f32 v2, v4, s13, s13
	v_minimum3_f32 v3, v5, s13, s13
	v_accvgpr_read_b32 v10, a50
	v_accvgpr_read_b32 v11, a51
	v_maximum3_f32 v5, v3, s16, s16
	v_maximum3_f32 v4, v2, s16, s16
	v_minimum3_f32 v2, v10, s13, s13
	v_minimum3_f32 v3, v11, s13, s13
	v_maximum3_f32 v9, v3, s16, s16
	v_maximum3_f32 v8, v2, s16, s16
	v_pk_mul_f32 v[96:97], v[96:97], v[110:111]
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[98:99]
	v_pk_add_f32 v[8:9], v[8:9], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[96:97]
	v_pk_mul_f32 v[0:1], v[8:9], v[0:1]
	s_mov_b32 s14, 0x3e2aaaab
	v_maximum3_f32 v2, |v5|, |v1|, |v1|
	v_maximum3_f32 v3, |v4|, |v0|, |v0|
	s_movk_i32 s17, 0xfe
	v_max_u32_dpp v2, v2, v2 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v3, v3, v3 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v117, 0
	v_max_u32_dpp v2, v2, v2 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v3, v3, v3 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v14, a60
	v_max_u32_dpp v2, v2, v2 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v3, v3, v3 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v116, 0
	v_max_u32_dpp v9, v2, v2 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v8, v3, v3 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[8:9], v[8:9], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v6, a56
	v_add_u32_e32 v2, 0x7fffff, v8
	v_lshrrev_b32_e32 v2, 23, v2
	v_min_u32_sdwa v113, v2, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_add_u32_e32 v3, 0x7fffff, v9
	v_lshlrev_b32_e32 v2, 23, v113
	v_cvt_scalef32_pk_fp4_f32 v117, v4, v0, v2
	v_lshrrev_b32_e32 v0, 23, v3
	v_min_u32_sdwa v112, v0, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v0, 23, v112
	v_cvt_scalef32_pk_fp4_f32 v116, v5, v1, v0
	v_minimum3_f32 v0, v126, s13, s13
	v_minimum3_f32 v2, v14, s13, s13
	v_mov_b32_e32 v4, v0
	v_mov_b32_e32 v5, v2
	v_pk_mul_f32 v[4:5], v[4:5], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v10, v6, s13, s13
	v_cmp_gt_f32_e32 vcc, s15, v5
	v_cmp_gt_f32_e64 s[0:1], s15, v4
	v_accvgpr_read_b32 v15, a61
	v_cndmask_b32_e32 v6, 0, v120, vcc
	v_add_f32_e32 v5, v5, v6
	v_cndmask_b32_e64 v6, 0, v120, s[0:1]
	v_add_f32_e32 v4, v4, v6
	v_exp_f32_e32 v5, v5
	v_exp_f32_e32 v4, v4
	v_cndmask_b32_e32 v6, 0, v124, vcc
	v_accvgpr_read_b32 v7, a57
	v_minimum3_f32 v1, v127, s13, s13
	v_minimum3_f32 v3, v15, s13, s13
	v_ldexp_f32 v5, v5, v6
	v_cndmask_b32_e64 v6, 0, v124, s[0:1]
	v_minimum3_f32 v11, v7, s13, s13
	v_ldexp_f32 v4, v4, v6
	v_mov_b32_e32 v6, v1
	v_mov_b32_e32 v7, v3
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e32 vcc, s15, v7
	v_cmp_gt_f32_e64 s[0:1], s15, v6
	v_accvgpr_read_b32 v12, a52
	v_cndmask_b32_e32 v8, 0, v120, vcc
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v7, v7
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e32 v8, 0, v124, vcc
	v_accvgpr_read_b32 v13, a53
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v6, v6, v8
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v8, v4
	v_rcp_f32_e32 v4, v5
	v_rcp_f32_e32 v5, v7
	v_rcp_f32_e32 v9, v6
	v_minimum3_f32 v12, v12, s13, s13
	v_minimum3_f32 v13, v13, s13, s13
	v_maximum3_f32 v7, v11, s16, s16
	v_maximum3_f32 v6, v10, s16, s16
	v_pk_mul_f32 v[2:3], v[2:3], v[4:5]
	v_maximum3_f32 v5, v13, s16, s16
	v_maximum3_f32 v4, v12, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[8:9]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[6:7], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_mov_b32_e32 v11, 0
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_mov_b32_e32 v13, 0
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_movk_i32 s18, 0x300
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_lshl_b32 s19, s24, 4
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v96, 0x7ffffff0
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	s_mul_i32 s6, s27, 0x300
	v_add_u32_e32 v4, 0x7fffff, v4
	v_lshrrev_b32_e32 v4, 23, v4
	v_min_u32_sdwa v10, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshlrev_b32_e32 v4, 23, v10
	v_cvt_scalef32_pk_fp4_f32 v11, v0, v2, v4
	v_lshrrev_b32_e32 v0, 23, v5
	v_min_u32_sdwa v12, v0, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v0, 23, v12
	v_cvt_scalef32_pk_fp4_f32 v13, v1, v3, v0
	v_minimum3_f32 v0, v16, s13, s13
	v_minimum3_f32 v2, v20, s13, s13
	v_mov_b32_e32 v4, v0
	v_mov_b32_e32 v5, v2
	v_pk_mul_f32 v[4:5], v[4:5], s[12:13] op_sel_hi:[1,0]
	s_mov_b32 s7, 0x27000
	v_cmp_gt_f32_e32 vcc, s15, v5
	v_cmp_gt_f32_e64 s[0:1], s15, v4
	s_mul_i32 s10, s27, 48
	v_cndmask_b32_e32 v1, 0, v120, vcc
	v_add_f32_e32 v1, v5, v1
	v_cndmask_b32_e64 v3, 0, v120, s[0:1]
	v_add_f32_e32 v3, v4, v3
	v_exp_f32_e32 v1, v1
	v_exp_f32_e32 v3, v3
	v_cndmask_b32_e32 v4, 0, v124, vcc
	s_mov_b32 s11, s7
	v_ldexp_f32 v5, v1, v4
	v_cndmask_b32_e64 v1, 0, v124, s[0:1]
	v_ldexp_f32 v4, v3, v1
	v_minimum3_f32 v1, v17, s13, s13
	v_minimum3_f32 v3, v21, s13, s13
	v_mov_b32_e32 v6, v1
	v_mov_b32_e32 v7, v3
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e32 vcc, s15, v7
	v_cmp_gt_f32_e64 s[0:1], s15, v6
	v_accvgpr_read_b32 v17, a48
	v_cndmask_b32_e32 v8, 0, v120, vcc
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v7, v7
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e32 v8, 0, v124, vcc
	v_cmp_eq_u32_e32 vcc, 0, v17
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v6, v6, v8
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v8, v4
	v_rcp_f32_e32 v4, v5
	v_rcp_f32_e32 v5, v7
	v_rcp_f32_e32 v9, v6
	v_minimum3_f32 v6, v24, s13, s13
	v_minimum3_f32 v7, v25, s13, s13
	v_pk_mul_f32 v[2:3], v[2:3], v[4:5]
	v_minimum3_f32 v4, v28, s13, s13
	v_minimum3_f32 v5, v29, s13, s13
	v_maximum3_f32 v7, v7, s16, s16
	v_maximum3_f32 v6, v6, s16, s16
	v_maximum3_f32 v5, v5, s16, s16
	v_maximum3_f32 v4, v4, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[8:9]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[6:7], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_mov_b32_e32 v7, 0
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	s_load_dwordx4 s[0:3], s[4:5], 0x40
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v9, v31, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s1, 0xffff
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_mov_b32 s4, s0
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v20, a20
	v_add_u32_e32 v4, 0x7fffff, v4
	v_lshrrev_b32_e32 v4, 23, v4
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshlrev_b32_e32 v6, 23, v4
	v_cvt_scalef32_pk_fp4_f32 v7, v0, v2, v6
	v_lshrrev_b32_e32 v0, 23, v5
	v_min_u32_sdwa v2, v0, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v0, 23, v2
	v_mov_b32_e32 v5, 0
	v_cvt_scalef32_pk_fp4_f32 v5, v1, v3, v0
	v_accvgpr_read_b32 v0, a49
	v_lshlrev_b32_e32 v0, 2, v0
	v_lshl_or_b32 v100, s31, 7, v0
	v_add_u32_e32 v0, s25, v100
	v_mul_lo_u32 v1, v0, s18
	v_add_u32_e32 v1, s19, v1
	v_or_b32_e32 v1, v1, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v100
	v_or_b32_e32 v16, 19, v100
	v_accvgpr_read_b32 v21, a21
	v_cndmask_b32_e64 v1, v96, v1, s[0:1]
	buffer_store_byte v117, v1, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[8:9], v0, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	s_and_b32 s9, s3, 0xffff
	s_mov_b32 s8, s2
	v_accvgpr_read_b32 v24, a12
	buffer_store_byte v113, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 1, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v3, v1, s18
	v_add_u32_e32 v3, s19, v3
	v_or_b32_e32 v3, v3, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_accvgpr_read_b32 v25, a13
	v_mov_b32_e32 v97, 0
	v_cndmask_b32_e64 v0, v96, v3, s[0:1]
	buffer_store_byte v116, v0, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v112, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 2, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v3, v1, s18
	v_add_u32_e32 v3, s19, v3
	v_or_b32_e32 v3, v3, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v96, v3, s[0:1]
	buffer_store_byte v11, v0, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v10, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 3, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v3, v1, s18
	v_add_u32_e32 v3, s19, v3
	v_or_b32_e32 v3, v3, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v96, v3, s[0:1]
	buffer_store_byte v13, v0, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v12, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 16, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v3, v1, s18
	v_add_u32_e32 v3, s19, v3
	v_or_b32_e32 v3, v3, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_or_b32_e32 v1, 17, v100
	v_cndmask_b32_e64 v3, v96, v3, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v7, v3, s[4:7], 0 offen
	buffer_store_byte v4, v0, s[8:11], 0 offen
	v_add_u32_e32 v0, s25, v1
	v_mul_lo_u32 v3, v0, s18
	v_add_u32_e32 v3, s19, v3
	v_or_b32_e32 v3, v3, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v1
	v_minimum3_f32 v4, v22, s13, s13
	v_mov_b32_e32 v7, v4
	v_cndmask_b32_e64 v1, v96, v3, s[0:1]
	buffer_store_byte v5, v1, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v0, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v2, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 18, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v1, v19, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v18, s13, s13
	v_mov_b32_e32 v6, v0
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v5, v23, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_mov_b32_e32 v10, v1
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_maximum3_f32 v13, v9, s16, s16
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v26, s13, s13
	v_minimum3_f32 v3, v27, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_minimum3_f32 v12, v30, s13, s13
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v12, v12, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_minimum3_f32 v9, v45, s13, s13
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v44, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v18, a16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v19, a17
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 32, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v36, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v32, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v33, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v37, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v40, s13, s13
	v_minimum3_f32 v3, v41, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 33, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v47, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v46, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v22, a22
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 34, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v38, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v34, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v35, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v39, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v42, s13, s13
	v_minimum3_f32 v3, v43, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 35, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v61, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v60, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v23, a23
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 48, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v52, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v48, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v49, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v53, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v56, s13, s13
	v_minimum3_f32 v3, v57, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 49, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v63, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v62, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v26, a14
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 50, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v54, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v50, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v51, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v55, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v58, s13, s13
	v_minimum3_f32 v3, v59, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 51, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v77, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v76, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v27, a15
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 64, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v68, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v64, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v65, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v69, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v72, s13, s13
	v_minimum3_f32 v3, v73, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x41, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v79, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v78, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	s_nop 0
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x42, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v70, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v66, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v67, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v71, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v74, s13, s13
	v_minimum3_f32 v3, v75, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x43, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v93, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v92, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	s_nop 0
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x50, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v84, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v80, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v81, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v85, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v88, s13, s13
	v_minimum3_f32 v3, v89, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x51, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v95, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v94, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	s_nop 0
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x52, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v86, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v82, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v83, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v87, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v90, s13, s13
	v_minimum3_f32 v3, v91, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x53, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_minimum3_f32 v9, v107, s13, s13
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v12, v106, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v12, v12, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	s_nop 0
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x60, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v18, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v20, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v21, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v19, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v102, s13, s13
	v_minimum3_f32 v3, v103, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x61, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_accvgpr_read_b32 v20, a18
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v21, a19
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v9, v109, s13, s13
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_maximum3_f32 v13, v9, s16, s16
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_minimum3_f32 v12, v108, s13, s13
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x62, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v20, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v22, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v23, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v21, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v104, s13, s13
	v_minimum3_f32 v3, v105, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v12, v12, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x63, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_accvgpr_read_b32 v20, a4
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v21, a5
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v19, a1
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v9, v19, s13, s13
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v23, a9
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x70, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v20, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v24, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v25, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v21, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_accvgpr_read_b32 v22, a8
	v_maximum3_f32 v13, v9, s16, s16
	v_rcp_f32_e32 v9, v11
	v_minimum3_f32 v2, v22, s13, s13
	v_minimum3_f32 v3, v23, s13, s13
	v_accvgpr_read_b32 v18, a0
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_minimum3_f32 v12, v18, s13, s13
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v12, v12, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x71, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
	v_maximum3_f32 v4, |v1|, |v3|, |v3|
	v_maximum3_f32 v5, |v0|, |v2|, |v2|
	v_accvgpr_read_b32 v22, a6
	v_max_u32_dpp v4, v4, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v23, a7
	v_max_u32_dpp v4, v4, v4 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v5, v5, v5 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_accvgpr_read_b32 v21, a3
	v_max_u32_dpp v4, v4, v4 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v6, v5, v5 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_minimum3_f32 v9, v21, s13, s13
	v_max_u32_dpp v5, v4, v4 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_max_u32_dpp v4, v6, v6 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_pk_mul_f32 v[4:5], v[4:5], s[14:15] op_sel_hi:[1,0]
	v_accvgpr_read_b32 v25, a11
	v_add_u32_e32 v4, 0x7fffff, v4
	v_add_u32_e32 v5, 0x7fffff, v5
	v_lshrrev_b32_e32 v4, 23, v4
	v_lshrrev_b32_e32 v5, 23, v5
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_mov_b32_e32 v0, 0
	v_cvt_scalef32_pk_fp4_f32 v0, v1, v3, v6
	v_add_u32_e32 v1, s25, v16
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cndmask_b32_e64 v2, v96, v2, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v0, v2, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v0, v96, v0, s[0:1]
	buffer_store_byte v5, v0, s[8:11], 0 offen
	v_or_b32_e32 v0, 0x72, v100
	v_add_u32_e32 v1, s25, v0
	v_mul_lo_u32 v2, v1, s18
	v_add_u32_e32 v2, s19, v2
	v_or_b32_e32 v2, v2, v17
	v_cmp_gt_i32_e64 s[0:1], s30, v0
	v_mad_u64_u32 v[0:1], s[2:3], v1, 48, s[24:25]
	v_minimum3_f32 v4, v22, s13, s13
	v_cndmask_b32_e64 v14, v96, v2, s[0:1]
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cndmask_b32_e64 v15, v96, v0, s[0:1]
	v_minimum3_f32 v0, v26, s13, s13
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v4
	v_pk_mul_f32 v[6:7], v[6:7], s[12:13] op_sel_hi:[1,0]
	v_minimum3_f32 v1, v27, s13, s13
	v_cmp_gt_f32_e64 s[0:1], s15, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_minimum3_f32 v5, v23, s13, s13
	v_cndmask_b32_e64 v8, 0, v120, s[0:1]
	v_add_f32_e32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, v6, v8
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, 0, v124, s[0:1]
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e64 v8, 0, v124, s[2:3]
	v_mov_b32_e32 v10, v1
	v_mov_b32_e32 v11, v5
	v_ldexp_f32 v6, v6, v8
	v_pk_mul_f32 v[10:11], v[10:11], s[12:13] op_sel_hi:[1,0]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[0:1], s15, v11
	v_rcp_f32_e32 v8, v7
	v_cmp_gt_f32_e64 s[2:3], s15, v10
	v_cndmask_b32_e64 v7, 0, v120, s[0:1]
	v_add_f32_e32 v7, v11, v7
	v_cndmask_b32_e64 v11, 0, v120, s[2:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, v10, v11
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v11, 0, v124, s[0:1]
	v_ldexp_f32 v11, v7, v11
	v_cndmask_b32_e64 v7, 0, v124, s[2:3]
	v_ldexp_f32 v10, v10, v7
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v10
	v_accvgpr_read_b32 v24, a10
	v_maximum3_f32 v13, v9, s16, s16
	v_rcp_f32_e32 v9, v11
	v_accvgpr_read_b32 v20, a2
	v_minimum3_f32 v2, v24, s13, s13
	v_minimum3_f32 v3, v25, s13, s13
	v_maximum3_f32 v3, v3, s16, s16
	v_maximum3_f32 v2, v2, s16, s16
	v_minimum3_f32 v12, v20, s13, s13
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_maximum3_f32 v12, v12, s16, s16
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	v_or_b32_e32 v16, 0x73, v100
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	v_pk_mul_f32 v[2:3], v[4:5], v[8:9]
	v_pk_add_f32 v[4:5], v[12:13], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v8, 0
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	v_cmp_gt_i32_e64 s[0:1], s30, v16
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
	v_min_u32_sdwa v4, v4, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_min_u32_sdwa v5, v5, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:DWORD
	v_lshlrev_b32_e32 v7, 23, v4
	v_lshlrev_b32_e32 v6, 23, v5
	v_cvt_scalef32_pk_fp4_f32 v8, v0, v2, v7
	v_add_u32_e32 v0, s25, v16
	v_cvt_scalef32_pk_fp4_f32 v97, v1, v3, v6
	v_mul_lo_u32 v1, v0, s18
	v_add_u32_e32 v1, s19, v1
	v_or_b32_e32 v1, v1, v17
	v_cndmask_b32_e64 v1, v96, v1, s[0:1]
	buffer_store_byte v8, v14, s[4:7], 0 offen
	buffer_store_byte v4, v15, s[8:11], 0 offen
	buffer_store_byte v97, v1, s[4:7], 0 offen
	v_mad_u64_u32 v[0:1], s[2:3], v0, 48, s[24:25]
	v_cndmask_b32_e32 v0, v96, v0, vcc
	buffer_store_byte v5, v0, s[8:11], 0 offen
.LBB0_198:
	s_endpgm
.Lfunc_end0:
	.size	flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef, .Lfunc_end0-flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef
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
		.amdhsa_next_free_vgpr 256
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 128
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

	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.num_vgpr, 128
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.num_agpr, 128
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.numbered_sgpr, 48
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.num_named_barrier, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.private_seg_size, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.uses_vcc, 1
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.uses_flat_scratch, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.has_dyn_sized_stack, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.has_recursion, 0
	.set .Lflymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.has_indirect_call, 0
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
  - .agpr_count:     128
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
    .name:           flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 512
      - 1
      - 1
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         flymoe_s1_k6144_n3072_bm256_w8x2_pingpong3_xcd_ef.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     256
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
