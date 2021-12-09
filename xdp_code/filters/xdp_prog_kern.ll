; ModuleID = 'xdp_prog_kern.c'
source_filename = "xdp_prog_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.iphdr = type { i8, i8, i16, i16, i16, i8, i8, i16, i32, i32 }

@morton_filter = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 64, i32 1, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !71
@llvm.compiler.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @morton_filter to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_morton_filter_func to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_morton_filter_func(%struct.xdp_md* nocapture readonly %0) #0 section "xdp_morton_filter" !dbg !163 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !175, metadata !DIExpression()), !dbg !276
  %3 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !277
  %4 = load i32, i32* %3, align 4, !dbg !277, !tbaa !278
  %5 = zext i32 %4 to i64, !dbg !283
  call void @llvm.dbg.value(metadata i64 %5, metadata !176, metadata !DIExpression()), !dbg !276
  %6 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !284
  %7 = load i32, i32* %6, align 4, !dbg !284, !tbaa !285
  %8 = zext i32 %7 to i64, !dbg !286
  %9 = inttoptr i64 %8 to i8*, !dbg !287
  call void @llvm.dbg.value(metadata i8* %9, metadata !177, metadata !DIExpression()), !dbg !276
  %10 = inttoptr i64 %8 to %struct.ethhdr*, !dbg !288
  call void @llvm.dbg.value(metadata %struct.ethhdr* %10, metadata !178, metadata !DIExpression()), !dbg !276
  %11 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 1, !dbg !289
  %12 = inttoptr i64 %5 to %struct.ethhdr*, !dbg !291
  %13 = icmp ugt %struct.ethhdr* %11, %12, !dbg !292
  br i1 %13, label %27, label %14, !dbg !293

14:                                               ; preds = %1
  %15 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 0, i32 2, !dbg !294
  %16 = load i16, i16* %15, align 1, !dbg !294, !tbaa !296
  %17 = icmp eq i16 %16, 8, !dbg !299
  br i1 %17, label %18, label %27, !dbg !300

18:                                               ; preds = %14
  call void @llvm.dbg.value(metadata i8* %9, metadata !192, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)), !dbg !276
  %19 = getelementptr i8, i8* %9, i64 34, !dbg !301
  %20 = bitcast i8* %19 to %struct.iphdr*, !dbg !301
  %21 = inttoptr i64 %5 to %struct.iphdr*, !dbg !303
  %22 = icmp ugt %struct.iphdr* %20, %21, !dbg !304
  br i1 %22, label %27, label %23, !dbg !305

23:                                               ; preds = %18
  call void @llvm.dbg.value(metadata i8* %9, metadata !192, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i8* %9, metadata !192, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)), !dbg !276
  %24 = getelementptr i8, i8* %9, i64 23, !dbg !306
  %25 = load i8, i8* %24, align 1, !dbg !306, !tbaa !308
  %26 = icmp eq i8 %25, 1, !dbg !310
  br i1 %26, label %29, label %27, !dbg !311

27:                                               ; preds = %29, %18, %23, %14, %1
  %28 = phi i32 [ 1, %1 ], [ 1, %14 ], [ %33, %29 ], [ 1, %18 ], [ 1, %23 ], !dbg !276
  ret i32 %28, !dbg !312

29:                                               ; preds = %23
  call void @llvm.dbg.value(metadata i64 0, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 0, i32 49, i32 1), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 1, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 1, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 48, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 48, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 48, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 49, i32 48, i32 256), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 12337, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 12337, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 2, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 48, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 2, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 12337, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 12337, i32 46, i32 65536), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 3026993, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 3026993, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 3, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 3, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 3026993, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 3026993, i32 49, i32 16777216), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 825110577, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 2018761857, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -297747415, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1027635061, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1027635061, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -250513321, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 4, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 4, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 0, i32 49, i32 1), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 5, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 5, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 49, i32 46, i32 256), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 256, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 11825, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 11825, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 6, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 6, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 11825, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 11825, i32 49, i32 65536), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 65536, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 3223089, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 3223089, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 7, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 49, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 7, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -1683241705, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 3223089, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 3223089, i32 46, i32 16777216), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 16777216, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 774975025, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -789824895, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 490793078, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1151330754, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -550228779, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -2053456922, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -2108025118, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -2108025118, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 8, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 46, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 8, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -2108025118, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !219, metadata !DIExpression(DW_OP_constu, 4, DW_OP_shr, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !220, metadata !DIExpression(DW_OP_constu, 15, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata !DIArgList(i32 0, i32 50, i32 1), metadata !223, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 15, DW_OP_and, DW_OP_LLVM_arg, 2, DW_OP_mul, DW_OP_plus, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression(DW_OP_constu, 16, DW_OP_mul, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !221, metadata !DIExpression(DW_OP_constu, 8, DW_OP_shl, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -2108025118, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 9, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !218, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i64 9, metadata !215, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !216, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !217, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !221, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -2108025118, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i8 undef, metadata !225, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i8 undef, metadata !226, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i8 undef, metadata !227, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1, metadata !224, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !224, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 undef, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 50, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -152774190, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 1827240818, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 -4293514, metadata !223, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 2112121492, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 2112121492, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 2112121501, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 2112100217, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 32393619, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 32392929, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 619944597, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 619953766, metadata !222, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 64, metadata !228, metadata !DIExpression()), !dbg !276
  call void @llvm.dbg.value(metadata i32 619953766, metadata !229, metadata !DIExpression(DW_OP_constu, 63, DW_OP_and, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 619953766, metadata !230, metadata !DIExpression(DW_OP_LLVM_convert, 32, DW_ATE_unsigned, DW_OP_LLVM_convert, 8, DW_ATE_unsigned, DW_OP_stack_value)), !dbg !276
  call void @llvm.dbg.value(metadata i32 619953766, metadata !231, metadata !DIExpression(DW_OP_constu, 63, DW_OP_and, DW_OP_stack_value)), !dbg !276
  %30 = bitcast i32* %2 to i8*, !dbg !313
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %30) #3, !dbg !313
  call void @llvm.dbg.value(metadata i32 0, metadata !232, metadata !DIExpression()), !dbg !276
  store i32 0, i32* %2, align 4, !dbg !314, !tbaa !315
  call void @llvm.dbg.value(metadata i32* %2, metadata !232, metadata !DIExpression(DW_OP_deref)), !dbg !276
  %31 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @morton_filter to i8*), i8* nonnull %30) #3, !dbg !316
  call void @llvm.dbg.value(metadata i8* %31, metadata !237, metadata !DIExpression()), !dbg !276
  %32 = icmp ne i8* %31, null, !dbg !317
  %33 = zext i1 %32 to i32, !dbg !319
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %30) #3, !dbg !312
  br label %27
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!158, !159, !160, !161}
!llvm.ident = !{!162}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "morton_filter", scope: !2, file: !3, line: 32, type: !150, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 13.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !45, globals: !52, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "xdp_prog_kern.c", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!4 = !{!5, !14}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 2845, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "../headers/linux/bpf.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2)
!12 = !DIEnumerator(name: "XDP_TX", value: 3)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!14 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !15, line: 40, baseType: !7, size: 32, elements: !16)
!15 = !DIFile(filename: "/usr/include/netinet/in.h", directory: "")
!16 = !{!17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44}
!17 = !DIEnumerator(name: "IPPROTO_IP", value: 0)
!18 = !DIEnumerator(name: "IPPROTO_ICMP", value: 1)
!19 = !DIEnumerator(name: "IPPROTO_IGMP", value: 2)
!20 = !DIEnumerator(name: "IPPROTO_IPIP", value: 4)
!21 = !DIEnumerator(name: "IPPROTO_TCP", value: 6)
!22 = !DIEnumerator(name: "IPPROTO_EGP", value: 8)
!23 = !DIEnumerator(name: "IPPROTO_PUP", value: 12)
!24 = !DIEnumerator(name: "IPPROTO_UDP", value: 17)
!25 = !DIEnumerator(name: "IPPROTO_IDP", value: 22)
!26 = !DIEnumerator(name: "IPPROTO_TP", value: 29)
!27 = !DIEnumerator(name: "IPPROTO_DCCP", value: 33)
!28 = !DIEnumerator(name: "IPPROTO_IPV6", value: 41)
!29 = !DIEnumerator(name: "IPPROTO_RSVP", value: 46)
!30 = !DIEnumerator(name: "IPPROTO_GRE", value: 47)
!31 = !DIEnumerator(name: "IPPROTO_ESP", value: 50)
!32 = !DIEnumerator(name: "IPPROTO_AH", value: 51)
!33 = !DIEnumerator(name: "IPPROTO_MTP", value: 92)
!34 = !DIEnumerator(name: "IPPROTO_BEETPH", value: 94)
!35 = !DIEnumerator(name: "IPPROTO_ENCAP", value: 98)
!36 = !DIEnumerator(name: "IPPROTO_PIM", value: 103)
!37 = !DIEnumerator(name: "IPPROTO_COMP", value: 108)
!38 = !DIEnumerator(name: "IPPROTO_SCTP", value: 132)
!39 = !DIEnumerator(name: "IPPROTO_UDPLITE", value: 136)
!40 = !DIEnumerator(name: "IPPROTO_MPLS", value: 137)
!41 = !DIEnumerator(name: "IPPROTO_ETHERNET", value: 143)
!42 = !DIEnumerator(name: "IPPROTO_RAW", value: 255)
!43 = !DIEnumerator(name: "IPPROTO_MPTCP", value: 262)
!44 = !DIEnumerator(name: "IPPROTO_MAX", value: 263)
!45 = !{!46, !47, !48, !51}
!46 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!47 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!48 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !49, line: 24, baseType: !50)
!49 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!50 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!51 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !49, line: 27, baseType: !7)
!52 = !{!0, !53, !57, !59, !63, !65, !67, !69, !71, !77, !140, !142}
!53 = !DIGlobalVariableExpression(var: !54, expr: !DIExpression(DW_OP_constu, 1, DW_OP_stack_value))
!54 = distinct !DIGlobalVariable(name: "NO_BLOCKS", scope: !2, file: !55, line: 6, type: !56, isLocal: true, isDefinition: true)
!55 = !DIFile(filename: "./morton_filter.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!56 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !51)
!57 = !DIGlobalVariableExpression(var: !58, expr: !DIExpression(DW_OP_constu, 64, DW_OP_stack_value))
!58 = distinct !DIGlobalVariable(name: "BUCKETS_PER_BLOCK", scope: !2, file: !55, line: 7, type: !56, isLocal: true, isDefinition: true)
!59 = !DIGlobalVariableExpression(var: !60, expr: !DIExpression(DW_OP_constu, 512, DW_OP_stack_value))
!60 = distinct !DIGlobalVariable(name: "BLOCKSIZE_BITS", scope: !2, file: !55, line: 5, type: !61, isLocal: true, isDefinition: true)
!61 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !62)
!62 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression(DW_OP_constu, 15, DW_OP_stack_value))
!64 = distinct !DIGlobalVariable(name: "OTA_BITS", scope: !2, file: !55, line: 8, type: !56, isLocal: true, isDefinition: true)
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression(DW_OP_constu, 368, DW_OP_stack_value))
!66 = distinct !DIGlobalVariable(name: "FSA_ARRAY_END", scope: !2, file: !55, line: 12, type: !56, isLocal: true, isDefinition: true)
!67 = !DIGlobalVariableExpression(var: !68, expr: !DIExpression(DW_OP_constu, 128, DW_OP_stack_value))
!68 = distinct !DIGlobalVariable(name: "FCA_ARRAY_END", scope: !2, file: !55, line: 13, type: !56, isLocal: true, isDefinition: true)
!69 = !DIGlobalVariableExpression(var: !70, expr: !DIExpression(DW_OP_constu, 2, DW_OP_stack_value))
!70 = distinct !DIGlobalVariable(name: "FCA_BITS", scope: !2, file: !55, line: 9, type: !56, isLocal: true, isDefinition: true)
!71 = !DIGlobalVariableExpression(var: !72, expr: !DIExpression())
!72 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 353, type: !73, isLocal: false, isDefinition: true)
!73 = !DICompositeType(tag: DW_TAG_array_type, baseType: !74, size: 32, elements: !75)
!74 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!75 = !{!76}
!76 = !DISubrange(count: 4)
!77 = !DIGlobalVariableExpression(var: !78, expr: !DIExpression())
!78 = distinct !DIGlobalVariable(name: "stdin", scope: !2, file: !79, line: 137, type: !80, isLocal: false, isDefinition: false)
!79 = !DIFile(filename: "/usr/include/stdio.h", directory: "")
!80 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !81, size: 64)
!81 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !82, line: 7, baseType: !83)
!82 = !DIFile(filename: "/usr/include/bits/types/FILE.h", directory: "")
!83 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !84, line: 49, size: 1728, elements: !85)
!84 = !DIFile(filename: "/usr/include/bits/types/struct_FILE.h", directory: "")
!85 = !{!86, !87, !89, !90, !91, !92, !93, !94, !95, !96, !97, !98, !99, !102, !104, !105, !106, !109, !110, !112, !116, !119, !123, !126, !129, !130, !131, !135, !136}
!86 = !DIDerivedType(tag: DW_TAG_member, name: "_flags", scope: !83, file: !84, line: 51, baseType: !62, size: 32)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_ptr", scope: !83, file: !84, line: 54, baseType: !88, size: 64, offset: 64)
!88 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !74, size: 64)
!89 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_end", scope: !83, file: !84, line: 55, baseType: !88, size: 64, offset: 128)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_base", scope: !83, file: !84, line: 56, baseType: !88, size: 64, offset: 192)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_base", scope: !83, file: !84, line: 57, baseType: !88, size: 64, offset: 256)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_ptr", scope: !83, file: !84, line: 58, baseType: !88, size: 64, offset: 320)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_end", scope: !83, file: !84, line: 59, baseType: !88, size: 64, offset: 384)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_base", scope: !83, file: !84, line: 60, baseType: !88, size: 64, offset: 448)
!95 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_end", scope: !83, file: !84, line: 61, baseType: !88, size: 64, offset: 512)
!96 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_base", scope: !83, file: !84, line: 64, baseType: !88, size: 64, offset: 576)
!97 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_backup_base", scope: !83, file: !84, line: 65, baseType: !88, size: 64, offset: 640)
!98 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_end", scope: !83, file: !84, line: 66, baseType: !88, size: 64, offset: 704)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "_markers", scope: !83, file: !84, line: 68, baseType: !100, size: 64, offset: 768)
!100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !101, size: 64)
!101 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_marker", file: !84, line: 36, flags: DIFlagFwdDecl)
!102 = !DIDerivedType(tag: DW_TAG_member, name: "_chain", scope: !83, file: !84, line: 70, baseType: !103, size: 64, offset: 832)
!103 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !83, size: 64)
!104 = !DIDerivedType(tag: DW_TAG_member, name: "_fileno", scope: !83, file: !84, line: 72, baseType: !62, size: 32, offset: 896)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "_flags2", scope: !83, file: !84, line: 73, baseType: !62, size: 32, offset: 928)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "_old_offset", scope: !83, file: !84, line: 74, baseType: !107, size: 64, offset: 960)
!107 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off_t", file: !108, line: 152, baseType: !47)
!108 = !DIFile(filename: "/usr/include/bits/types.h", directory: "")
!109 = !DIDerivedType(tag: DW_TAG_member, name: "_cur_column", scope: !83, file: !84, line: 77, baseType: !50, size: 16, offset: 1024)
!110 = !DIDerivedType(tag: DW_TAG_member, name: "_vtable_offset", scope: !83, file: !84, line: 78, baseType: !111, size: 8, offset: 1040)
!111 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!112 = !DIDerivedType(tag: DW_TAG_member, name: "_shortbuf", scope: !83, file: !84, line: 79, baseType: !113, size: 8, offset: 1048)
!113 = !DICompositeType(tag: DW_TAG_array_type, baseType: !74, size: 8, elements: !114)
!114 = !{!115}
!115 = !DISubrange(count: 1)
!116 = !DIDerivedType(tag: DW_TAG_member, name: "_lock", scope: !83, file: !84, line: 81, baseType: !117, size: 64, offset: 1088)
!117 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !118, size: 64)
!118 = !DIDerivedType(tag: DW_TAG_typedef, name: "_IO_lock_t", file: !84, line: 43, baseType: null)
!119 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !83, file: !84, line: 89, baseType: !120, size: 64, offset: 1152)
!120 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off64_t", file: !108, line: 153, baseType: !121)
!121 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !108, line: 47, baseType: !122)
!122 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!123 = !DIDerivedType(tag: DW_TAG_member, name: "_codecvt", scope: !83, file: !84, line: 91, baseType: !124, size: 64, offset: 1216)
!124 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !125, size: 64)
!125 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_codecvt", file: !84, line: 37, flags: DIFlagFwdDecl)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "_wide_data", scope: !83, file: !84, line: 92, baseType: !127, size: 64, offset: 1280)
!127 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !128, size: 64)
!128 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_wide_data", file: !84, line: 38, flags: DIFlagFwdDecl)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_list", scope: !83, file: !84, line: 93, baseType: !103, size: 64, offset: 1344)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_buf", scope: !83, file: !84, line: 94, baseType: !46, size: 64, offset: 1408)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "__pad5", scope: !83, file: !84, line: 95, baseType: !132, size: 64, offset: 1472)
!132 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !133, line: 46, baseType: !134)
!133 = !DIFile(filename: "/usr/lib/clang/13.0.0/include/stddef.h", directory: "")
!134 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "_mode", scope: !83, file: !84, line: 96, baseType: !62, size: 32, offset: 1536)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "_unused2", scope: !83, file: !84, line: 98, baseType: !137, size: 160, offset: 1568)
!137 = !DICompositeType(tag: DW_TAG_array_type, baseType: !74, size: 160, elements: !138)
!138 = !{!139}
!139 = !DISubrange(count: 20)
!140 = !DIGlobalVariableExpression(var: !141, expr: !DIExpression())
!141 = distinct !DIGlobalVariable(name: "stdout", scope: !2, file: !79, line: 138, type: !80, isLocal: false, isDefinition: false)
!142 = !DIGlobalVariableExpression(var: !143, expr: !DIExpression())
!143 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !144, line: 33, type: !145, isLocal: true, isDefinition: true)
!144 = !DIFile(filename: "../libbpf/src/build/usr/include/bpf/bpf_helper_defs.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!145 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !146, size: 64)
!146 = !DISubroutineType(types: !147)
!147 = !{!46, !46, !148}
!148 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !149, size: 64)
!149 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!150 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !151, line: 33, size: 160, elements: !152)
!151 = !DIFile(filename: "../libbpf/src/build/usr/include/bpf/bpf_helpers.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!152 = !{!153, !154, !155, !156, !157}
!153 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !150, file: !151, line: 34, baseType: !7, size: 32)
!154 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !150, file: !151, line: 35, baseType: !7, size: 32, offset: 32)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !150, file: !151, line: 36, baseType: !7, size: 32, offset: 64)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !150, file: !151, line: 37, baseType: !7, size: 32, offset: 96)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !150, file: !151, line: 38, baseType: !7, size: 32, offset: 128)
!158 = !{i32 7, !"Dwarf Version", i32 4}
!159 = !{i32 2, !"Debug Info Version", i32 3}
!160 = !{i32 1, !"wchar_size", i32 4}
!161 = !{i32 7, !"frame-pointer", i32 2}
!162 = !{!"clang version 13.0.0"}
!163 = distinct !DISubprogram(name: "xdp_morton_filter_func", scope: !3, file: !3, line: 46, type: !164, scopeLine: 47, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !174)
!164 = !DISubroutineType(types: !165)
!165 = !{!62, !166}
!166 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !167, size: 64)
!167 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !168)
!168 = !{!169, !170, !171, !172, !173}
!169 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !167, file: !6, line: 2857, baseType: !51, size: 32)
!170 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !167, file: !6, line: 2858, baseType: !51, size: 32, offset: 32)
!171 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !167, file: !6, line: 2859, baseType: !51, size: 32, offset: 64)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !167, file: !6, line: 2861, baseType: !51, size: 32, offset: 96)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !167, file: !6, line: 2862, baseType: !51, size: 32, offset: 128)
!174 = !{!175, !176, !177, !178, !192, !211, !215, !216, !217, !218, !219, !220, !221, !222, !223, !224, !225, !226, !227, !228, !229, !230, !231, !232, !233, !237, !239, !240, !241, !242, !243, !244, !245, !246, !250, !251, !252, !253, !254, !255, !256, !257, !258, !261, !262, !263, !264, !268, !269, !270, !271, !272, !273, !274, !275}
!175 = !DILocalVariable(name: "ctx", arg: 1, scope: !163, file: !3, line: 46, type: !166)
!176 = !DILocalVariable(name: "data_end", scope: !163, file: !3, line: 53, type: !46)
!177 = !DILocalVariable(name: "data", scope: !163, file: !3, line: 54, type: !46)
!178 = !DILocalVariable(name: "eth", scope: !163, file: !3, line: 55, type: !179)
!179 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !180, size: 64)
!180 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !181, line: 165, size: 112, elements: !182)
!181 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!182 = !{!183, !188, !189}
!183 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !180, file: !181, line: 166, baseType: !184, size: 48)
!184 = !DICompositeType(tag: DW_TAG_array_type, baseType: !185, size: 48, elements: !186)
!185 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!186 = !{!187}
!187 = !DISubrange(count: 6)
!188 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !180, file: !181, line: 167, baseType: !184, size: 48, offset: 48)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !180, file: !181, line: 168, baseType: !190, size: 16, offset: 96)
!190 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !191, line: 25, baseType: !48)
!191 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!192 = !DILocalVariable(name: "iph", scope: !163, file: !3, line: 68, type: !193)
!193 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !194, size: 64)
!194 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !195, line: 86, size: 160, elements: !196)
!195 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!196 = !{!197, !199, !200, !201, !202, !203, !204, !205, !206, !208, !210}
!197 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !194, file: !195, line: 88, baseType: !198, size: 4, flags: DIFlagBitField, extraData: i64 0)
!198 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !49, line: 21, baseType: !185)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !194, file: !195, line: 89, baseType: !198, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !194, file: !195, line: 96, baseType: !198, size: 8, offset: 8)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !194, file: !195, line: 97, baseType: !190, size: 16, offset: 16)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !194, file: !195, line: 98, baseType: !190, size: 16, offset: 32)
!203 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !194, file: !195, line: 99, baseType: !190, size: 16, offset: 48)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !194, file: !195, line: 100, baseType: !198, size: 8, offset: 64)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !194, file: !195, line: 101, baseType: !198, size: 8, offset: 72)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !194, file: !195, line: 102, baseType: !207, size: 16, offset: 80)
!207 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !191, line: 31, baseType: !48)
!208 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !194, file: !195, line: 103, baseType: !209, size: 32, offset: 96)
!209 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !191, line: 27, baseType: !51)
!210 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !194, file: !195, line: 104, baseType: !209, size: 32, offset: 128)
!211 = !DILocalVariable(name: "name", scope: !163, file: !3, line: 108, type: !212)
!212 = !DICompositeType(tag: DW_TAG_array_type, baseType: !74, size: 80, elements: !213)
!213 = !{!214}
!214 = !DISubrange(count: 10)
!215 = !DILocalVariable(name: "i", scope: !163, file: !3, line: 117, type: !51)
!216 = !DILocalVariable(name: "byte", scope: !163, file: !3, line: 118, type: !51)
!217 = !DILocalVariable(name: "prev_byte", scope: !163, file: !3, line: 119, type: !51)
!218 = !DILocalVariable(name: "prev_prev_byte", scope: !163, file: !3, line: 120, type: !51)
!219 = !DILocalVariable(name: "upper_16", scope: !163, file: !3, line: 121, type: !51)
!220 = !DILocalVariable(name: "lower_16", scope: !163, file: !3, line: 122, type: !51)
!221 = !DILocalVariable(name: "multiplier", scope: !163, file: !3, line: 123, type: !51)
!222 = !DILocalVariable(name: "h1", scope: !163, file: !3, line: 126, type: !51)
!223 = !DILocalVariable(name: "k", scope: !163, file: !3, line: 127, type: !51)
!224 = !DILocalVariable(name: "remains", scope: !163, file: !3, line: 158, type: !51)
!225 = !DILocalVariable(name: "tail0", scope: !163, file: !3, line: 159, type: !198)
!226 = !DILocalVariable(name: "tail1", scope: !163, file: !3, line: 160, type: !198)
!227 = !DILocalVariable(name: "tail2", scope: !163, file: !3, line: 161, type: !198)
!228 = !DILocalVariable(name: "n", scope: !163, file: !3, line: 196, type: !51)
!229 = !DILocalVariable(name: "hash1", scope: !163, file: !3, line: 198, type: !51)
!230 = !DILocalVariable(name: "fp", scope: !163, file: !3, line: 199, type: !198)
!231 = !DILocalVariable(name: "glbi1", scope: !163, file: !3, line: 201, type: !51)
!232 = !DILocalVariable(name: "block1", scope: !163, file: !3, line: 202, type: !51)
!233 = !DILocalVariable(name: "b", scope: !163, file: !3, line: 203, type: !234)
!234 = !DICompositeType(tag: DW_TAG_array_type, baseType: !198, size: 512, elements: !235)
!235 = !{!236}
!236 = !DISubrange(count: 64)
!237 = !DILocalVariable(name: "block", scope: !163, file: !3, line: 204, type: !238)
!238 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !198, size: 64)
!239 = !DILocalVariable(name: "lbi1", scope: !163, file: !3, line: 215, type: !51)
!240 = !DILocalVariable(name: "ota_index", scope: !163, file: !3, line: 216, type: !50)
!241 = !DILocalVariable(name: "ota_bit", scope: !163, file: !3, line: 217, type: !50)
!242 = !DILocalVariable(name: "found", scope: !163, file: !3, line: 218, type: !62)
!243 = !DILocalVariable(name: "bucket_capacities", scope: !163, file: !3, line: 221, type: !51)
!244 = !DILocalVariable(name: "index", scope: !163, file: !3, line: 222, type: !51)
!245 = !DILocalVariable(name: "cap", scope: !163, file: !3, line: 223, type: !51)
!246 = !DILocalVariable(name: "first_item", scope: !247, file: !3, line: 228, type: !62)
!247 = distinct !DILexicalBlock(scope: !248, file: !3, line: 225, column: 23)
!248 = distinct !DILexicalBlock(scope: !249, file: !3, line: 225, column: 2)
!249 = distinct !DILexicalBlock(scope: !163, file: !3, line: 225, column: 2)
!250 = !DILocalVariable(name: "second_item", scope: !247, file: !3, line: 229, type: !62)
!251 = !DILocalVariable(name: "third_item", scope: !247, file: !3, line: 230, type: !62)
!252 = !DILocalVariable(name: "fourth_item", scope: !247, file: !3, line: 231, type: !62)
!253 = !DILocalVariable(name: "item", scope: !247, file: !3, line: 237, type: !198)
!254 = !DILocalVariable(name: "temp_cap", scope: !247, file: !3, line: 238, type: !198)
!255 = !DILocalVariable(name: "mask", scope: !247, file: !3, line: 239, type: !198)
!256 = !DILocalVariable(name: "cand_fp", scope: !163, file: !3, line: 265, type: !198)
!257 = !DILocalVariable(name: "buc", scope: !163, file: !3, line: 266, type: !62)
!258 = !DILocalVariable(name: "hash2", scope: !259, file: !3, line: 283, type: !51)
!259 = distinct !DILexicalBlock(scope: !260, file: !3, line: 282, column: 7)
!260 = distinct !DILexicalBlock(scope: !163, file: !3, line: 279, column: 6)
!261 = !DILocalVariable(name: "glbi2", scope: !259, file: !3, line: 284, type: !51)
!262 = !DILocalVariable(name: "block2", scope: !259, file: !3, line: 285, type: !51)
!263 = !DILocalVariable(name: "lbi2", scope: !259, file: !3, line: 291, type: !51)
!264 = !DILocalVariable(name: "first_item", scope: !265, file: !3, line: 297, type: !62)
!265 = distinct !DILexicalBlock(scope: !266, file: !3, line: 294, column: 24)
!266 = distinct !DILexicalBlock(scope: !267, file: !3, line: 294, column: 3)
!267 = distinct !DILexicalBlock(scope: !259, file: !3, line: 294, column: 3)
!268 = !DILocalVariable(name: "second_item", scope: !265, file: !3, line: 298, type: !62)
!269 = !DILocalVariable(name: "third_item", scope: !265, file: !3, line: 299, type: !62)
!270 = !DILocalVariable(name: "fourth_item", scope: !265, file: !3, line: 300, type: !62)
!271 = !DILocalVariable(name: "item", scope: !265, file: !3, line: 306, type: !198)
!272 = !DILocalVariable(name: "temp_cap", scope: !265, file: !3, line: 307, type: !198)
!273 = !DILocalVariable(name: "mask", scope: !265, file: !3, line: 308, type: !198)
!274 = !DILocalVariable(name: "cand_fp", scope: !259, file: !3, line: 334, type: !198)
!275 = !DILocalVariable(name: "buc", scope: !259, file: !3, line: 335, type: !62)
!276 = !DILocation(line: 0, scope: !163)
!277 = !DILocation(line: 53, column: 38, scope: !163)
!278 = !{!279, !280, i64 4}
!279 = !{!"xdp_md", !280, i64 0, !280, i64 4, !280, i64 8, !280, i64 12, !280, i64 16}
!280 = !{!"int", !281, i64 0}
!281 = !{!"omnipotent char", !282, i64 0}
!282 = !{!"Simple C/C++ TBAA"}
!283 = !DILocation(line: 53, column: 27, scope: !163)
!284 = !DILocation(line: 54, column: 34, scope: !163)
!285 = !{!279, !280, i64 0}
!286 = !DILocation(line: 54, column: 23, scope: !163)
!287 = !DILocation(line: 54, column: 15, scope: !163)
!288 = !DILocation(line: 55, column: 23, scope: !163)
!289 = !DILocation(line: 58, column: 10, scope: !290)
!290 = distinct !DILexicalBlock(scope: !163, file: !3, line: 58, column: 6)
!291 = !DILocation(line: 58, column: 16, scope: !290)
!292 = !DILocation(line: 58, column: 14, scope: !290)
!293 = !DILocation(line: 58, column: 6, scope: !163)
!294 = !DILocation(line: 63, column: 6, scope: !295)
!295 = distinct !DILexicalBlock(scope: !163, file: !3, line: 63, column: 6)
!296 = !{!297, !298, i64 12}
!297 = !{!"ethhdr", !281, i64 0, !281, i64 6, !298, i64 12}
!298 = !{!"short", !281, i64 0}
!299 = !DILocation(line: 63, column: 30, scope: !295)
!300 = !DILocation(line: 63, column: 6, scope: !163)
!301 = !DILocation(line: 69, column: 10, scope: !302)
!302 = distinct !DILexicalBlock(scope: !163, file: !3, line: 69, column: 6)
!303 = !DILocation(line: 69, column: 16, scope: !302)
!304 = !DILocation(line: 69, column: 14, scope: !302)
!305 = !DILocation(line: 69, column: 6, scope: !163)
!306 = !DILocation(line: 72, column: 11, scope: !307)
!307 = distinct !DILexicalBlock(scope: !163, file: !3, line: 72, column: 6)
!308 = !{!309, !281, i64 9}
!309 = !{!"iphdr", !281, i64 0, !281, i64 0, !281, i64 1, !298, i64 2, !298, i64 4, !298, i64 6, !281, i64 8, !281, i64 9, !298, i64 10, !280, i64 12, !280, i64 16}
!310 = !DILocation(line: 72, column: 20, scope: !307)
!311 = !DILocation(line: 72, column: 6, scope: !163)
!312 = !DILocation(line: 352, column: 1, scope: !163)
!313 = !DILocation(line: 202, column: 2, scope: !163)
!314 = !DILocation(line: 202, column: 8, scope: !163)
!315 = !{!280, !280, i64 0}
!316 = !DILocation(line: 205, column: 8, scope: !163)
!317 = !DILocation(line: 206, column: 7, scope: !318)
!318 = distinct !DILexicalBlock(scope: !163, file: !3, line: 206, column: 6)
!319 = !DILocation(line: 206, column: 6, scope: !163)
