; ModuleID = 'xdp_prog_kern.c'
source_filename = "xdp_prog_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.iphdr = type { i8, i8, i16, i16, i16, i8, i8, i16, i32, i32 }

@morton_filter = dso_local global %struct.bpf_map_def { i32 2, i32 4, i32 64, i32 44, i32 0 }, section "maps", align 4, !dbg !0
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1, !dbg !65
@llvm.compiler.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (%struct.bpf_map_def* @morton_filter to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_morton_filter_func to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @xdp_morton_filter_func(%struct.xdp_md* nocapture readonly %0) #0 section "xdp_morton_filter" !dbg !164 {
  %2 = alloca i32, align 4
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !176, metadata !DIExpression()), !dbg !227
  %3 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !228
  %4 = load i32, i32* %3, align 4, !dbg !228, !tbaa !229
  %5 = zext i32 %4 to i64, !dbg !234
  call void @llvm.dbg.value(metadata i64 %5, metadata !177, metadata !DIExpression()), !dbg !227
  %6 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !235
  %7 = load i32, i32* %6, align 4, !dbg !235, !tbaa !236
  %8 = zext i32 %7 to i64, !dbg !237
  %9 = inttoptr i64 %8 to i8*, !dbg !238
  call void @llvm.dbg.value(metadata i8* %9, metadata !178, metadata !DIExpression()), !dbg !227
  %10 = inttoptr i64 %8 to %struct.ethhdr*, !dbg !239
  call void @llvm.dbg.value(metadata %struct.ethhdr* %10, metadata !179, metadata !DIExpression()), !dbg !227
  %11 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 1, !dbg !240
  %12 = inttoptr i64 %5 to %struct.ethhdr*, !dbg !242
  %13 = icmp ugt %struct.ethhdr* %11, %12, !dbg !243
  br i1 %13, label %33, label %14, !dbg !244

14:                                               ; preds = %1
  %15 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %10, i64 0, i32 2, !dbg !245
  %16 = load i16, i16* %15, align 1, !dbg !245, !tbaa !247
  %17 = icmp eq i16 %16, 8, !dbg !250
  br i1 %17, label %18, label %33, !dbg !251

18:                                               ; preds = %14
  call void @llvm.dbg.value(metadata i8* %9, metadata !192, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)), !dbg !227
  %19 = getelementptr i8, i8* %9, i64 34, !dbg !252
  %20 = bitcast i8* %19 to %struct.iphdr*, !dbg !252
  %21 = inttoptr i64 %5 to %struct.iphdr*, !dbg !254
  %22 = icmp ugt %struct.iphdr* %20, %21, !dbg !255
  br i1 %22, label %33, label %23, !dbg !256

23:                                               ; preds = %18
  call void @llvm.dbg.value(metadata i8* %9, metadata !192, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)), !dbg !227
  call void @llvm.dbg.value(metadata i8* %9, metadata !192, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)), !dbg !227
  %24 = getelementptr i8, i8* %9, i64 23, !dbg !257
  %25 = load i8, i8* %24, align 1, !dbg !257, !tbaa !259
  %26 = icmp eq i8 %25, 1, !dbg !261
  br i1 %26, label %35, label %33, !dbg !262

27:                                               ; preds = %35, %27
  %28 = phi i32 [ %29, %27 ], [ 38, %35 ]
  call void @llvm.dbg.value(metadata i32 undef, metadata !263, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !273, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !271, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !272, metadata !DIExpression(DW_OP_plus_uconst, 368, DW_OP_stack_value)), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !263, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !273, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !263, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !273, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !271, metadata !DIExpression(DW_OP_constu, 1, DW_OP_or, DW_OP_stack_value)), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !272, metadata !DIExpression(DW_OP_plus_uconst, 368, DW_OP_stack_value)), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !263, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !273, metadata !DIExpression()), !dbg !285
  call void @llvm.dbg.value(metadata !DIArgList(i32 undef, i32 undef), metadata !263, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_plus, DW_OP_stack_value)), !dbg !285
  call void @llvm.dbg.value(metadata !DIArgList(i32 undef, i32 undef), metadata !273, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_plus, DW_OP_stack_value)), !dbg !285
  call void @llvm.dbg.value(metadata i32 undef, metadata !271, metadata !DIExpression(DW_OP_plus_uconst, 2, DW_OP_stack_value)), !dbg !285
  %29 = add i32 %28, -2, !dbg !287
  %30 = icmp eq i32 %29, 0, !dbg !287
  br i1 %30, label %31, label %27, !dbg !287, !llvm.loop !288

31:                                               ; preds = %27, %35
  %32 = phi i32 [ 0, %35 ], [ 2, %27 ], !dbg !227
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %36) #3, !dbg !292
  br label %33

33:                                               ; preds = %31, %18, %23, %14, %1
  %34 = phi i32 [ 1, %1 ], [ 1, %14 ], [ %32, %31 ], [ 1, %18 ], [ 1, %23 ], !dbg !227
  ret i32 %34, !dbg !292

35:                                               ; preds = %23
  call void @llvm.dbg.value(metadata i8 102, metadata !214, metadata !DIExpression()), !dbg !227
  call void @llvm.dbg.value(metadata i32 102, metadata !215, metadata !DIExpression()), !dbg !227
  %36 = bitcast i32* %2 to i8*, !dbg !293
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %36) #3, !dbg !293
  call void @llvm.dbg.value(metadata i32 1, metadata !216, metadata !DIExpression()), !dbg !227
  store i32 1, i32* %2, align 4, !dbg !294, !tbaa !295
  call void @llvm.dbg.value(metadata i32* %2, metadata !216, metadata !DIExpression(DW_OP_deref)), !dbg !227
  %37 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @morton_filter to i8*), i8* nonnull %36) #3, !dbg !296
  call void @llvm.dbg.value(metadata i8* %37, metadata !217, metadata !DIExpression()), !dbg !227
  %38 = icmp eq i8* %37, null, !dbg !297
  br i1 %38, label %31, label %27, !dbg !299
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
!llvm.module.flags = !{!159, !160, !161, !162}
!llvm.ident = !{!163}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "morton_filter", scope: !2, file: !3, line: 29, type: !151, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 13.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !45, globals: !53, splitDebugInlining: false, nameTableKind: None)
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
!51 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !49, line: 21, baseType: !52)
!52 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!53 = !{!0, !54, !59, !61, !63, !65, !71, !135, !137, !139, !147, !149}
!54 = !DIGlobalVariableExpression(var: !55, expr: !DIExpression(DW_OP_constu, 64, DW_OP_stack_value))
!55 = distinct !DIGlobalVariable(name: "BUCKETS_PER_BLOCK", scope: !2, file: !56, line: 7, type: !57, isLocal: true, isDefinition: true)
!56 = !DIFile(filename: "./morton_filter.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!57 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !58)
!58 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !49, line: 27, baseType: !7)
!59 = !DIGlobalVariableExpression(var: !60, expr: !DIExpression(DW_OP_constu, 15, DW_OP_stack_value))
!60 = distinct !DIGlobalVariable(name: "OTA_BITS", scope: !2, file: !56, line: 8, type: !57, isLocal: true, isDefinition: true)
!61 = !DIGlobalVariableExpression(var: !62, expr: !DIExpression(DW_OP_constu, 368, DW_OP_stack_value))
!62 = distinct !DIGlobalVariable(name: "FSA_ARRAY_END", scope: !2, file: !56, line: 12, type: !57, isLocal: true, isDefinition: true)
!63 = !DIGlobalVariableExpression(var: !64, expr: !DIExpression(DW_OP_constu, 128, DW_OP_stack_value))
!64 = distinct !DIGlobalVariable(name: "FCA_ARRAY_END", scope: !2, file: !56, line: 13, type: !57, isLocal: true, isDefinition: true)
!65 = !DIGlobalVariableExpression(var: !66, expr: !DIExpression())
!66 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 124, type: !67, isLocal: false, isDefinition: true)
!67 = !DICompositeType(tag: DW_TAG_array_type, baseType: !68, size: 32, elements: !69)
!68 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!69 = !{!70}
!70 = !DISubrange(count: 4)
!71 = !DIGlobalVariableExpression(var: !72, expr: !DIExpression())
!72 = distinct !DIGlobalVariable(name: "stdin", scope: !2, file: !73, line: 137, type: !74, isLocal: false, isDefinition: false)
!73 = !DIFile(filename: "/usr/include/stdio.h", directory: "")
!74 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !75, size: 64)
!75 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !76, line: 7, baseType: !77)
!76 = !DIFile(filename: "/usr/include/bits/types/FILE.h", directory: "")
!77 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !78, line: 49, size: 1728, elements: !79)
!78 = !DIFile(filename: "/usr/include/bits/types/struct_FILE.h", directory: "")
!79 = !{!80, !82, !84, !85, !86, !87, !88, !89, !90, !91, !92, !93, !94, !97, !99, !100, !101, !104, !105, !107, !111, !114, !118, !121, !124, !125, !126, !130, !131}
!80 = !DIDerivedType(tag: DW_TAG_member, name: "_flags", scope: !77, file: !78, line: 51, baseType: !81, size: 32)
!81 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!82 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_ptr", scope: !77, file: !78, line: 54, baseType: !83, size: 64, offset: 64)
!83 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !68, size: 64)
!84 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_end", scope: !77, file: !78, line: 55, baseType: !83, size: 64, offset: 128)
!85 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_base", scope: !77, file: !78, line: 56, baseType: !83, size: 64, offset: 192)
!86 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_base", scope: !77, file: !78, line: 57, baseType: !83, size: 64, offset: 256)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_ptr", scope: !77, file: !78, line: 58, baseType: !83, size: 64, offset: 320)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_end", scope: !77, file: !78, line: 59, baseType: !83, size: 64, offset: 384)
!89 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_base", scope: !77, file: !78, line: 60, baseType: !83, size: 64, offset: 448)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_end", scope: !77, file: !78, line: 61, baseType: !83, size: 64, offset: 512)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_base", scope: !77, file: !78, line: 64, baseType: !83, size: 64, offset: 576)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_backup_base", scope: !77, file: !78, line: 65, baseType: !83, size: 64, offset: 640)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_end", scope: !77, file: !78, line: 66, baseType: !83, size: 64, offset: 704)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "_markers", scope: !77, file: !78, line: 68, baseType: !95, size: 64, offset: 768)
!95 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !96, size: 64)
!96 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_marker", file: !78, line: 36, flags: DIFlagFwdDecl)
!97 = !DIDerivedType(tag: DW_TAG_member, name: "_chain", scope: !77, file: !78, line: 70, baseType: !98, size: 64, offset: 832)
!98 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !77, size: 64)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "_fileno", scope: !77, file: !78, line: 72, baseType: !81, size: 32, offset: 896)
!100 = !DIDerivedType(tag: DW_TAG_member, name: "_flags2", scope: !77, file: !78, line: 73, baseType: !81, size: 32, offset: 928)
!101 = !DIDerivedType(tag: DW_TAG_member, name: "_old_offset", scope: !77, file: !78, line: 74, baseType: !102, size: 64, offset: 960)
!102 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off_t", file: !103, line: 152, baseType: !47)
!103 = !DIFile(filename: "/usr/include/bits/types.h", directory: "")
!104 = !DIDerivedType(tag: DW_TAG_member, name: "_cur_column", scope: !77, file: !78, line: 77, baseType: !50, size: 16, offset: 1024)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "_vtable_offset", scope: !77, file: !78, line: 78, baseType: !106, size: 8, offset: 1040)
!106 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "_shortbuf", scope: !77, file: !78, line: 79, baseType: !108, size: 8, offset: 1048)
!108 = !DICompositeType(tag: DW_TAG_array_type, baseType: !68, size: 8, elements: !109)
!109 = !{!110}
!110 = !DISubrange(count: 1)
!111 = !DIDerivedType(tag: DW_TAG_member, name: "_lock", scope: !77, file: !78, line: 81, baseType: !112, size: 64, offset: 1088)
!112 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !113, size: 64)
!113 = !DIDerivedType(tag: DW_TAG_typedef, name: "_IO_lock_t", file: !78, line: 43, baseType: null)
!114 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !77, file: !78, line: 89, baseType: !115, size: 64, offset: 1152)
!115 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off64_t", file: !103, line: 153, baseType: !116)
!116 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !103, line: 47, baseType: !117)
!117 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!118 = !DIDerivedType(tag: DW_TAG_member, name: "_codecvt", scope: !77, file: !78, line: 91, baseType: !119, size: 64, offset: 1216)
!119 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !120, size: 64)
!120 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_codecvt", file: !78, line: 37, flags: DIFlagFwdDecl)
!121 = !DIDerivedType(tag: DW_TAG_member, name: "_wide_data", scope: !77, file: !78, line: 92, baseType: !122, size: 64, offset: 1280)
!122 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !123, size: 64)
!123 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_wide_data", file: !78, line: 38, flags: DIFlagFwdDecl)
!124 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_list", scope: !77, file: !78, line: 93, baseType: !98, size: 64, offset: 1344)
!125 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_buf", scope: !77, file: !78, line: 94, baseType: !46, size: 64, offset: 1408)
!126 = !DIDerivedType(tag: DW_TAG_member, name: "__pad5", scope: !77, file: !78, line: 95, baseType: !127, size: 64, offset: 1472)
!127 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !128, line: 46, baseType: !129)
!128 = !DIFile(filename: "/usr/lib/clang/13.0.0/include/stddef.h", directory: "")
!129 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "_mode", scope: !77, file: !78, line: 96, baseType: !81, size: 32, offset: 1536)
!131 = !DIDerivedType(tag: DW_TAG_member, name: "_unused2", scope: !77, file: !78, line: 98, baseType: !132, size: 160, offset: 1568)
!132 = !DICompositeType(tag: DW_TAG_array_type, baseType: !68, size: 160, elements: !133)
!133 = !{!134}
!134 = !DISubrange(count: 20)
!135 = !DIGlobalVariableExpression(var: !136, expr: !DIExpression())
!136 = distinct !DIGlobalVariable(name: "stdout", scope: !2, file: !73, line: 138, type: !74, isLocal: false, isDefinition: false)
!137 = !DIGlobalVariableExpression(var: !138, expr: !DIExpression(DW_OP_constu, 44, DW_OP_stack_value))
!138 = distinct !DIGlobalVariable(name: "NO_BLOCKS", scope: !2, file: !56, line: 6, type: !57, isLocal: true, isDefinition: true)
!139 = !DIGlobalVariableExpression(var: !140, expr: !DIExpression())
!140 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !141, line: 33, type: !142, isLocal: true, isDefinition: true)
!141 = !DIFile(filename: "../libbpf/src/build/usr/include/bpf/bpf_helper_defs.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!142 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !143, size: 64)
!143 = !DISubroutineType(types: !144)
!144 = !{!46, !46, !145}
!145 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !146, size: 64)
!146 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!147 = !DIGlobalVariableExpression(var: !148, expr: !DIExpression(DW_OP_constu, 2, DW_OP_stack_value))
!148 = distinct !DIGlobalVariable(name: "FCA_BITS", scope: !2, file: !56, line: 9, type: !57, isLocal: true, isDefinition: true)
!149 = !DIGlobalVariableExpression(var: !150, expr: !DIExpression(DW_OP_constu, 8, DW_OP_stack_value))
!150 = distinct !DIGlobalVariable(name: "FINGERPRINT_SIZE", scope: !2, file: !56, line: 11, type: !57, isLocal: true, isDefinition: true)
!151 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !152, line: 33, size: 160, elements: !153)
!152 = !DIFile(filename: "../libbpf/src/build/usr/include/bpf/bpf_helpers.h", directory: "/home/anastasia/diplomatiki/xdp_code/filters")
!153 = !{!154, !155, !156, !157, !158}
!154 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !151, file: !152, line: 34, baseType: !7, size: 32)
!155 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !151, file: !152, line: 35, baseType: !7, size: 32, offset: 32)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !151, file: !152, line: 36, baseType: !7, size: 32, offset: 64)
!157 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !151, file: !152, line: 37, baseType: !7, size: 32, offset: 96)
!158 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !151, file: !152, line: 38, baseType: !7, size: 32, offset: 128)
!159 = !{i32 7, !"Dwarf Version", i32 4}
!160 = !{i32 2, !"Debug Info Version", i32 3}
!161 = !{i32 1, !"wchar_size", i32 4}
!162 = !{i32 7, !"frame-pointer", i32 2}
!163 = !{!"clang version 13.0.0"}
!164 = distinct !DISubprogram(name: "xdp_morton_filter_func", scope: !3, file: !3, line: 43, type: !165, scopeLine: 44, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !175)
!165 = !DISubroutineType(types: !166)
!166 = !{!81, !167}
!167 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !168, size: 64)
!168 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 2856, size: 160, elements: !169)
!169 = !{!170, !171, !172, !173, !174}
!170 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !168, file: !6, line: 2857, baseType: !58, size: 32)
!171 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !168, file: !6, line: 2858, baseType: !58, size: 32, offset: 32)
!172 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !168, file: !6, line: 2859, baseType: !58, size: 32, offset: 64)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !168, file: !6, line: 2861, baseType: !58, size: 32, offset: 96)
!174 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !168, file: !6, line: 2862, baseType: !58, size: 32, offset: 128)
!175 = !{!176, !177, !178, !179, !192, !210, !214, !215, !216, !217, !219, !220, !221, !222, !225, !226}
!176 = !DILocalVariable(name: "ctx", arg: 1, scope: !164, file: !3, line: 43, type: !167)
!177 = !DILocalVariable(name: "data_end", scope: !164, file: !3, line: 50, type: !46)
!178 = !DILocalVariable(name: "data", scope: !164, file: !3, line: 51, type: !46)
!179 = !DILocalVariable(name: "eth", scope: !164, file: !3, line: 52, type: !180)
!180 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !181, size: 64)
!181 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !182, line: 165, size: 112, elements: !183)
!182 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!183 = !{!184, !188, !189}
!184 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !181, file: !182, line: 166, baseType: !185, size: 48)
!185 = !DICompositeType(tag: DW_TAG_array_type, baseType: !52, size: 48, elements: !186)
!186 = !{!187}
!187 = !DISubrange(count: 6)
!188 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !181, file: !182, line: 167, baseType: !185, size: 48, offset: 48)
!189 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !181, file: !182, line: 168, baseType: !190, size: 16, offset: 96)
!190 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !191, line: 25, baseType: !48)
!191 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!192 = !DILocalVariable(name: "iph", scope: !164, file: !3, line: 65, type: !193)
!193 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !194, size: 64)
!194 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !195, line: 86, size: 160, elements: !196)
!195 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!196 = !{!197, !198, !199, !200, !201, !202, !203, !204, !205, !207, !209}
!197 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !194, file: !195, line: 88, baseType: !51, size: 4, flags: DIFlagBitField, extraData: i64 0)
!198 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !194, file: !195, line: 89, baseType: !51, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!199 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !194, file: !195, line: 96, baseType: !51, size: 8, offset: 8)
!200 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !194, file: !195, line: 97, baseType: !190, size: 16, offset: 16)
!201 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !194, file: !195, line: 98, baseType: !190, size: 16, offset: 32)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !194, file: !195, line: 99, baseType: !190, size: 16, offset: 48)
!203 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !194, file: !195, line: 100, baseType: !51, size: 8, offset: 64)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !194, file: !195, line: 101, baseType: !51, size: 8, offset: 72)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !194, file: !195, line: 102, baseType: !206, size: 16, offset: 80)
!206 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !191, line: 31, baseType: !48)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !194, file: !195, line: 103, baseType: !208, size: 32, offset: 96)
!208 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !191, line: 27, baseType: !58)
!209 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !194, file: !195, line: 104, baseType: !208, size: 32, offset: 128)
!210 = !DILocalVariable(name: "item", scope: !164, file: !3, line: 79, type: !211)
!211 = !DICompositeType(tag: DW_TAG_array_type, baseType: !68, size: 80, elements: !212)
!212 = !{!213}
!213 = !DISubrange(count: 10)
!214 = !DILocalVariable(name: "fp", scope: !164, file: !3, line: 88, type: !51)
!215 = !DILocalVariable(name: "glbi1", scope: !164, file: !3, line: 90, type: !58)
!216 = !DILocalVariable(name: "block1", scope: !164, file: !3, line: 91, type: !58)
!217 = !DILocalVariable(name: "b", scope: !164, file: !3, line: 92, type: !218)
!218 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !58, size: 64)
!219 = !DILocalVariable(name: "lbi1", scope: !164, file: !3, line: 103, type: !58)
!220 = !DILocalVariable(name: "ota_index", scope: !164, file: !3, line: 104, type: !50)
!221 = !DILocalVariable(name: "ota_bit", scope: !164, file: !3, line: 105, type: !50)
!222 = !DILocalVariable(name: "glbi2", scope: !223, file: !3, line: 111, type: !58)
!223 = distinct !DILexicalBlock(scope: !224, file: !3, line: 110, column: 7)
!224 = distinct !DILexicalBlock(scope: !164, file: !3, line: 107, column: 6)
!225 = !DILocalVariable(name: "block2", scope: !223, file: !3, line: 112, type: !58)
!226 = !DILocalVariable(name: "lbi2", scope: !223, file: !3, line: 117, type: !58)
!227 = !DILocation(line: 0, scope: !164)
!228 = !DILocation(line: 50, column: 38, scope: !164)
!229 = !{!230, !231, i64 4}
!230 = !{!"xdp_md", !231, i64 0, !231, i64 4, !231, i64 8, !231, i64 12, !231, i64 16}
!231 = !{!"int", !232, i64 0}
!232 = !{!"omnipotent char", !233, i64 0}
!233 = !{!"Simple C/C++ TBAA"}
!234 = !DILocation(line: 50, column: 27, scope: !164)
!235 = !DILocation(line: 51, column: 34, scope: !164)
!236 = !{!230, !231, i64 0}
!237 = !DILocation(line: 51, column: 23, scope: !164)
!238 = !DILocation(line: 51, column: 15, scope: !164)
!239 = !DILocation(line: 52, column: 23, scope: !164)
!240 = !DILocation(line: 55, column: 10, scope: !241)
!241 = distinct !DILexicalBlock(scope: !164, file: !3, line: 55, column: 6)
!242 = !DILocation(line: 55, column: 16, scope: !241)
!243 = !DILocation(line: 55, column: 14, scope: !241)
!244 = !DILocation(line: 55, column: 6, scope: !164)
!245 = !DILocation(line: 60, column: 6, scope: !246)
!246 = distinct !DILexicalBlock(scope: !164, file: !3, line: 60, column: 6)
!247 = !{!248, !249, i64 12}
!248 = !{!"ethhdr", !232, i64 0, !232, i64 6, !249, i64 12}
!249 = !{!"short", !232, i64 0}
!250 = !DILocation(line: 60, column: 30, scope: !246)
!251 = !DILocation(line: 60, column: 6, scope: !164)
!252 = !DILocation(line: 66, column: 10, scope: !253)
!253 = distinct !DILexicalBlock(scope: !164, file: !3, line: 66, column: 6)
!254 = !DILocation(line: 66, column: 16, scope: !253)
!255 = !DILocation(line: 66, column: 14, scope: !253)
!256 = !DILocation(line: 66, column: 6, scope: !164)
!257 = !DILocation(line: 70, column: 11, scope: !258)
!258 = distinct !DILexicalBlock(scope: !164, file: !3, line: 70, column: 6)
!259 = !{!260, !232, i64 9}
!260 = !{!"iphdr", !232, i64 0, !232, i64 0, !232, i64 1, !249, i64 2, !249, i64 4, !249, i64 6, !232, i64 8, !232, i64 9, !249, i64 10, !231, i64 12, !231, i64 16}
!261 = !DILocation(line: 70, column: 20, scope: !258)
!262 = !DILocation(line: 70, column: 6, scope: !164)
!263 = !DILocalVariable(name: "bucket_capacities", scope: !264, file: !56, line: 139, type: !58)
!264 = distinct !DISubprogram(name: "read_and_cmp", scope: !56, file: !56, line: 138, type: !265, scopeLine: 138, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !267)
!265 = !DISubroutineType(types: !266)
!266 = !{!81, !218, !58, !51}
!267 = !{!268, !269, !270, !263, !271, !272, !273, !274, !279, !282, !283, !284}
!268 = !DILocalVariable(name: "block", arg: 1, scope: !264, file: !56, line: 138, type: !218)
!269 = !DILocalVariable(name: "lbi", arg: 2, scope: !264, file: !56, line: 138, type: !58)
!270 = !DILocalVariable(name: "fp", arg: 3, scope: !264, file: !56, line: 138, type: !51)
!271 = !DILocalVariable(name: "i", scope: !264, file: !56, line: 140, type: !81)
!272 = !DILocalVariable(name: "index", scope: !264, file: !56, line: 140, type: !81)
!273 = !DILocalVariable(name: "cap", scope: !264, file: !56, line: 141, type: !58)
!274 = !DILocalVariable(name: "j", scope: !275, file: !56, line: 148, type: !81)
!275 = distinct !DILexicalBlock(scope: !276, file: !56, line: 148, column: 3)
!276 = distinct !DILexicalBlock(scope: !277, file: !56, line: 143, column: 22)
!277 = distinct !DILexicalBlock(scope: !278, file: !56, line: 143, column: 2)
!278 = distinct !DILexicalBlock(scope: !264, file: !56, line: 143, column: 2)
!279 = !DILocalVariable(name: "bit", scope: !280, file: !56, line: 149, type: !50)
!280 = distinct !DILexicalBlock(scope: !281, file: !56, line: 148, column: 31)
!281 = distinct !DILexicalBlock(scope: !275, file: !56, line: 148, column: 3)
!282 = !DILocalVariable(name: "found", scope: !264, file: !56, line: 160, type: !81)
!283 = !DILocalVariable(name: "cand_fp", scope: !264, file: !56, line: 161, type: !51)
!284 = !DILocalVariable(name: "buc", scope: !264, file: !56, line: 162, type: !81)
!285 = !DILocation(line: 0, scope: !264, inlinedAt: !286)
!286 = distinct !DILocation(line: 107, column: 6, scope: !224)
!287 = !DILocation(line: 143, column: 2, scope: !278, inlinedAt: !286)
!288 = distinct !{!288, !287, !289, !290, !291}
!289 = !DILocation(line: 156, column: 2, scope: !278, inlinedAt: !286)
!290 = !{!"llvm.loop.mustprogress"}
!291 = !{!"llvm.loop.unroll.disable"}
!292 = !DILocation(line: 123, column: 1, scope: !164)
!293 = !DILocation(line: 91, column: 2, scope: !164)
!294 = !DILocation(line: 91, column: 8, scope: !164)
!295 = !{!231, !231, i64 0}
!296 = !DILocation(line: 93, column: 4, scope: !164)
!297 = !DILocation(line: 94, column: 7, scope: !298)
!298 = distinct !DILexicalBlock(scope: !164, file: !3, line: 94, column: 6)
!299 = !DILocation(line: 94, column: 6, scope: !164)
