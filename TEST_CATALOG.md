# Swift/ObjC Test Catalog

**Total Tests:** 105

**Numbered Tests:** 105

**Unnumbered Tests:** 0

**Numbered Tests Missing Descriptions:** 0

**Numbering Mismatches:** 0

All numbered test numbers are unique.

This catalog lists all tests in the Swift/ObjC codebase.

| Test # | Function Name | Description | File |
|--------|---------------|-------------|------|
| test0001 | `test0001_op_execution` | TEST0001: Run Op::perform and verify the returned value matches what the op was configured with | Tests/OpsTests/OpTests.swift:14 |
| test0002 | `test0002_op_with_contexts` | TEST0002: Verify Op reads from DryContext and produces a formatted result using that data | Tests/OpsTests/OpTests.swift:23 |
| test0003 | `test0003_op_default_rollback` | TEST0003: Confirm that the default rollback implementation is a no-op that always succeeds | Tests/OpsTests/OpTests.swift:40 |
| test0004 | `test0004_op_custom_rollback` | TEST0004: Verify a custom rollback implementation is called and sets the rolled_back flag | Tests/OpsTests/OpTests.swift:53 |
| test0005 | `test0005_perform_with_auto_logging` | TEST0005: Confirm the perform() utility wraps an op with automatic logging and returns its result | Tests/OpsTests/OpsUtilTests.swift:13 |
| test0006 | `test0006_caller_trigger_name` | TEST0006: Verify callerTriggerName() returns a string containing "::" | Tests/OpsTests/OpsUtilTests.swift:21 |
| test0007 | `test0007_wrap_nested_op_exception` | TEST0007: Confirm wrapNestedOpException wraps an error with the op name in the message | Tests/OpsTests/OpsUtilTests.swift:28 |
| test0008 | `test0008_wrap_runtime_exception` | TEST0008: Verify wrapRuntimeException converts a standard error into an OpError.executionFailed | Tests/OpsTests/OpsUtilTests.swift:40 |
| test0009 | `test0009_dry_context_basic_operations` | TEST0009: Insert typed values into DryContext and verify get/contains work correctly | Tests/OpsTests/DryContextTests.swift:7 |
| test0010 | `test0010_dry_context_builder` | TEST0010: Build a DryContext with chained with-value calls and verify all values are stored | Tests/OpsTests/DryContextTests.swift:19 |
| test0011 | `test0011_wet_context_basic_operations` | TEST0011: Insert a reference into WetContext and retrieve it by type via getRef | Tests/OpsTests/WetContextTests.swift:7 |
| test0012 | `test0012_wet_context_builder` | TEST0012: Build a WetContext with chained withRef calls and verify contains for each key | Tests/OpsTests/WetContextTests.swift:22 |
| test0013 | `test0013_required_values` | TEST0013: Confirm getRequired succeeds for present keys and returns an error for missing keys | Tests/OpsTests/DryContextTests.swift:29 |
| test0014 | `test0014_context_merge` | TEST0014: Merge two DryContexts and verify values from both are accessible in the target | Tests/OpsTests/DryContextTests.swift:37 |
| test0015 | `test0015_dry_context_type_mismatch_error` | TEST0015: Verify getRequired returns a Type mismatch error when the stored type doesn't match | Tests/OpsTests/DryContextTests.swift:46 |
| test0016 | `test0016_wet_context_type_mismatch_error` | TEST0016: Verify WetContext getRequired returns a Type mismatch error when the stored ref type differs | Tests/OpsTests/WetContextTests.swift:35 |
| test0017 | `test0017_control_flags` | TEST0017: Set and clear abort flags on DryContext and verify isAborted and abortReason reflect state | Tests/OpsTests/DryContextTests.swift:67 |
| test0018 | `test0018_control_flags_merge` | TEST0018: Merge contexts with abort flags and confirm the target inherits the abort state correctly | Tests/OpsTests/DryContextTests.swift:83 |
| test0019 | `test0019_get_or_insert_with` | TEST0019: Verify getOrInsert inserts when missing and returns existing without calling factory | Tests/OpsTests/DryContextTests.swift:102 |
| test0020 | `test0020_get_or_compute_with` | TEST0020: Verify getOrCompute computes and stores a value using context data | Tests/OpsTests/DryContextTests.swift:119 |
| test0021 | `test0021_metadata_builder` | TEST0021: Build OpMetadata with name, description, and schemas and verify all fields are populated | Tests/OpsTests/OpMetadataTests.swift:7 |
| test0022 | `test0022_trigger_fuse` | TEST0022: Construct a TriggerFuse with data and verify the trigger name and dry context values | Tests/OpsTests/OpMetadataTests.swift:25 |
| test0023 | `test0023_basic_validation` | TEST0023: Validate a DryContext against an input schema and confirm valid/invalid reports | Tests/OpsTests/OpMetadataTests.swift:36 |
| test0024 | `test0024_simple_flat_outline` | TEST0024: Build a flat ListingOutline with depth-0 entries and verify maxDepth, levels, and flatten count | Tests/OpsTests/StructuredQueriesTests.swift:7 |
| test0025 | `test0025_hierarchical_outline` | TEST0025: Build a two-level outline with chapters and sections and verify depth, level counts, and flatten | Tests/OpsTests/StructuredQueriesTests.swift:22 |
| test0026 | `test0026_complex_part_based_outline` | TEST0026: Build a three-level part/chapter/section outline and verify depth and per-level entry counts | Tests/OpsTests/StructuredQueriesTests.swift:43 |
| test0027 | `test0027_flatten_preserves_hierarchy` | TEST0027: Flatten a nested outline and verify each entry's path reflects its ancestry correctly | Tests/OpsTests/StructuredQueriesTests.swift:73 |
| test0028 | `test0028_schema_generation` | TEST0028: Call generateOutlineSchema and verify the returned dictionary contains all required definitions | Tests/OpsTests/StructuredQueriesTests.swift:90 |
| test0029 | `test0029_logging_wrapper_success` | TEST0029: Wrap a successful op in LoggingWrapper and verify it passes through the result unchanged | Tests/OpsTests/LoggingWrapperTests.swift:27 |
| test0030 | `test0030_logging_wrapper_failure` | TEST0030: Wrap a failing op in LoggingWrapper and verify the error includes the op name context | Tests/OpsTests/LoggingWrapperTests.swift:36 |
| test0031 | `test0031_context_aware_logger` | TEST0031: Use createContextAwareLogger helper and verify the wrapped op returns its result | Tests/OpsTests/LoggingWrapperTests.swift:51 |
| test0032 | `test0032_ansi_color_constants` | TEST0032: Verify ANSI color escape code constants have the expected ANSI sequence values | Tests/OpsTests/LoggingWrapperTests.swift:60 |
| test0033 | `test0033_timeout_wrapper_success` | TEST0033: Wrap a fast op in TimeBoundWrapper and confirm it completes before the timeout | Tests/OpsTests/TimeBoundWrapperTests.swift:43 |
| test0034 | `test0034_timeout_wrapper_timeout` | TEST0034: Wrap a slow op in TimeBoundWrapper with a short timeout and verify a Timeout error is returned | Tests/OpsTests/TimeBoundWrapperTests.swift:52 |
| test0035 | `test0035_timeout_wrapper_with_name` | TEST0035: Create a named TimeBoundWrapper and verify the op succeeds and returns the expected value | Tests/OpsTests/TimeBoundWrapperTests.swift:67 |
| test0036 | `test0036_caller_name_wrapper` | TEST0036: Use createTimeoutWrapperWithCallerName helper and verify the op result is returned | Tests/OpsTests/TimeBoundWrapperTests.swift:76 |
| test0037 | `test0037_logged_timeout_wrapper` | TEST0037: Use createLoggedTimeoutWrapper to compose logging and timeout wrappers and verify success | Tests/OpsTests/TimeBoundWrapperTests.swift:85 |
| test0038 | `test0038_valid_input_output` | TEST0038: Run ValidatingWrapper with a valid input and verify the op executes and returns the result | Tests/OpsTests/ValidatingWrapperTests.swift:34 |
| test0039 | `test0039_invalid_input_missing_required` | TEST0039: Run ValidatingWrapper without a required input field and verify a Context validation error | Tests/OpsTests/ValidatingWrapperTests.swift:44 |
| test0040 | `test0040_invalid_input_out_of_range` | TEST0040: Run ValidatingWrapper with an input exceeding the schema maximum and verify a validation error | Tests/OpsTests/ValidatingWrapperTests.swift:59 |
| test0041 | `test0041_input_only_validation` | TEST0041: Use ValidatingWrapper.inputOnly and confirm input is validated while output is not | Tests/OpsTests/ValidatingWrapperTests.swift:75 |
| test0042 | `test0042_output_only_validation` | TEST0042: Use ValidatingWrapper.outputOnly and confirm output is validated while input is not | Tests/OpsTests/ValidatingWrapperTests.swift:100 |
| test0043 | `test0043_no_schema_validation` | TEST0043: Wrap an op with no schemas in ValidatingWrapper and confirm it still succeeds | Tests/OpsTests/ValidatingWrapperTests.swift:124 |
| test0044 | `test0044_metadata_transparency` | TEST0044: Verify ValidatingWrapper.metadata() delegates to the inner op's metadata unchanged | Tests/OpsTests/ValidatingWrapperTests.swift:138 |
| test0045 | `test0045_reference_validation` | TEST0045: Verify ValidatingWrapper checks reference_schema and rejects when required refs are missing | Tests/OpsTests/ValidatingWrapperTests.swift:148 |
| test0046 | `test0046_no_reference_schema` | TEST0046: Wrap an op with no reference schema in ValidatingWrapper and confirm it succeeds | Tests/OpsTests/ValidatingWrapperTests.swift:196 |
| test0047 | `test0047_batch_metadata_with_data_flow` | TEST0047: Build BatchMetadata from producer/consumer ops and verify only external inputs are required | Tests/OpsTests/BatchMetadataTests.swift:7 |
| test0048 | `test0048_reference_schema_merging` | TEST0048: Build BatchMetadata from two ops with different reference schemas and verify union of required refs | Tests/OpsTests/BatchMetadataTests.swift:64 |
| test0049 | `test0049_batch_op_success` | TEST0049: Run BatchOp with two succeeding ops and verify results contain both values in order | Tests/OpsTests/BatchOpTests.swift:18 |
| test0050 | `test0050_batch_op_failure` | TEST0050: Run BatchOp where the second op fails and verify the batch returns an error | Tests/OpsTests/BatchOpTests.swift:28 |
| test0051 | `test0051_batch_op_returns_all_results` | TEST0051: Run BatchOp with two ops and verify both result values are present in order | Tests/OpsTests/BatchOpTests.swift:42 |
| test0052 | `test0052_batch_metadata_data_flow` | TEST0052: Verify BatchOp metadata correctly identifies only the externally-required input fields | Tests/OpsTests/BatchOpTests.swift:302 |
| test0053 | `test0053_batch_reference_schema_merging` | TEST0053: Verify BatchOp merges reference schemas from all ops into a unified set of required refs | Tests/OpsTests/BatchOpTests.swift:54 |
| test0054 | `test0054_batch_rollback_on_failure` | TEST0054: Run BatchOp where the third op fails and verify rollback is called on the first two but not the third | Tests/OpsTests/BatchOpTests.swift:96 |
| test0055 | `test0055_batch_rollback_order` | TEST0055: Run BatchOp where the last op fails and verify rollback occurs in reverse (LIFO) order | Tests/OpsTests/BatchOpTests.swift:159 |
| test0056 | `test0056_batch_rollback_on_failure_partial` | TEST0056: Run BatchOp where one op fails and verify rollback is triggered for succeeded ops | Tests/OpsTests/BatchOpTests.swift:194 |
| test0057 | `test0057_abort_without_reason` | TEST0057: Invoke the abort pattern without a reason and verify the context is aborted with no reason string | Tests/OpsTests/ControlFlowTests.swift:54 |
| test0058 | `test0058_abort_with_reason` | TEST0058: Invoke the abort pattern with a reason string and verify abort_reason matches | Tests/OpsTests/ControlFlowTests.swift:72 |
| test0059 | `test0059_continue_loop_via_context_flag` | TEST0059: Signal continue from inside an op using the context flag and verify subsequent ops are skipped | Tests/OpsTests/ControlFlowTests.swift:90 |
| test0060 | `test0060_check_abort_pattern` | TEST0060: Use check_abort pattern to short-circuit when the abort flag is already set in context | Tests/OpsTests/ControlFlowTests.swift:119 |
| test0061 | `test0061_batch_op_with_abort` | TEST0061: Run a BatchOp where the second op aborts and verify the batch stops and propagates the abort | Tests/OpsTests/ControlFlowTests.swift:138 |
| test0062 | `test0062_batch_op_with_pre_existing_abort` | TEST0062: Start a BatchOp with an abort flag already set and verify it immediately returns Aborted | Tests/OpsTests/ControlFlowTests.swift:159 |
| test0063 | `test0063_loop_op_with_continue` | TEST0063: Run a LoopOp where an op signals continue and verify subsequent ops in the iteration are skipped | Tests/OpsTests/ControlFlowTests.swift:180 |
| test0064 | `test0064_loop_op_with_abort` | TEST0064: Run a LoopOp where an op aborts mid-loop and verify the loop terminates with the abort error | Tests/OpsTests/ControlFlowTests.swift:213 |
| test0065 | `test0065_loop_op_with_pre_existing_abort` | TEST0065: Start a LoopOp with an abort flag already set and verify it immediately returns Aborted | Tests/OpsTests/ControlFlowTests.swift:237 |
| test0066 | `test0066_complex_control_flow_scenario` | TEST0066: Nest a batch with a continue op inside a loop and verify results across all iterations | Tests/OpsTests/ControlFlowTests.swift:258 |
| test0067 | `test0067_loop_op_basic` | TEST0067: Run a LoopOp for 3 iterations with 2 ops each and verify all 6 results in order | Tests/OpsTests/LoopOpTests.swift:22 |
| test0068 | `test0068_loop_op_with_counter_access` | TEST0068: Run a LoopOp where each op reads the loop counter and verify values are 0, 1, 2 | Tests/OpsTests/LoopOpTests.swift:32 |
| test0069 | `test0069_loop_op_existing_counter` | TEST0069: Start a LoopOp with a pre-initialized counter and verify it only executes remaining iterations | Tests/OpsTests/LoopOpTests.swift:41 |
| test0070 | `test0070_loop_op_zero_limit` | TEST0070: Run a LoopOp with a zero iteration limit and verify no ops are executed | Tests/OpsTests/LoopOpTests.swift:52 |
| test0071 | `test0071_loop_op_builder_pattern` | TEST0071: Build a LoopOp with addOp chaining and verify all added ops run across all iterations | Tests/OpsTests/LoopOpTests.swift:61 |
| test0072 | `test0072_loop_op_rollback_on_iteration_failure` | TEST0072: Run a LoopOp where the third op fails and verify succeeded ops are rolled back in reverse order | Tests/OpsTests/LoopOpTests.swift:72 |
| test0073 | `test0073_loop_op_rollback_order_within_iteration` | TEST0073: Run a LoopOp where the last op fails and verify rollback occurs in LIFO order within the iteration | Tests/OpsTests/LoopOpTests.swift:103 |
| test0074 | `test0074_loop_op_successful_iterations_not_rolled_back` | TEST0074: Run a LoopOp that fails on iteration 2 and verify previously completed iterations are not rolled back | Tests/OpsTests/LoopOpTests.swift:234 |
| test0075 | `test0075_loop_op_mixed_iteration_with_rollback` | TEST0075: Run a LoopOp where op2 fails on iteration 1 and verify only op1 from that iteration is rolled back | Tests/OpsTests/LoopOpTests.swift:280 |
| test0076 | `test0076_loop_op_continue_on_error` | TEST0076: Run a LoopOp configured to continue on error and verify subsequent iterations still execute | Tests/OpsTests/LoopOpTests.swift:136 |
| test0077 | `test0077_dry_put_and_get` | TEST0077: Use dryPut and dryGet to store and retrieve a typed value by variable name | Tests/OpsTests/ContextHelpersTests.swift:7 |
| test0078 | `test0078_dry_require` | TEST0078: Use dryRequire to retrieve a required value and verify error when key is missing | Tests/OpsTests/ContextHelpersTests.swift:16 |
| test0079 | `test0079_dry_result` | TEST0079: Use dryResult to store a final result and verify it is stored under both "result" and op name | Tests/OpsTests/ContextHelpersTests.swift:28 |
| test0080 | `test0080_wet_put_ref_and_require_ref` | TEST0080: Use wetPutRef and wetRequireRef to store and retrieve a service reference | Tests/OpsTests/ContextHelpersTests.swift:38 |
| test0081 | `test0081_wet_put_ref_arc_style` | TEST0081: Store a service via wetPutRef and retrieve it via wetRequireRef | Tests/OpsTests/ContextHelpersTests.swift:52 |
| test0082 | `test0082_helpers_in_op` | TEST0082: Run a full op that uses dryRequire and wetRequireRef helpers internally and verify the output | Tests/OpsTests/ContextHelpersTests.swift:66 |
| test0093 | `test0093_batch_len_and_is_empty` | TEST0093: Call BatchOp.count and isEmpty on empty and non-empty batches | Tests/OpsTests/BatchOpTests.swift:226 |
| test0094 | `test0094_batch_add_op` | TEST0094: Use addOp to dynamically add an op and verify it is executed | Tests/OpsTests/BatchOpTests.swift:366 |
| test0095 | `test0095_batch_continue_on_error` | TEST0095: Run BatchOp with continueOnError and verify it collects results past failures | Tests/OpsTests/BatchOpTests.swift:237 |
| test0096 | `test0096_empty_batch_returns_empty` | TEST0096: Run an empty BatchOp and verify it returns an empty result array | Tests/OpsTests/BatchOpTests.swift:250 |
| test0097 | `test0097_nested_batch_rollback` | TEST0097: Verify nested BatchOp rollback propagates correctly when outer batch fails | Tests/OpsTests/BatchOpTests.swift:258 |
| test0098 | `test0098_dry_context_merge_overwrites_keys` | TEST0098: Merge two DryContexts where keys overlap and verify the merging context's values win | Tests/OpsTests/DryContextTests.swift:145 |
| test0099 | `test0099_wet_context_merge` | TEST0099: Merge two WetContexts and verify both sets of references are accessible in the target | Tests/OpsTests/WetContextTests.swift:58 |
| test0100 | `test0100_dry_context_serde_roundtrip` | TEST0100: Serialize and deserialize a DryContext JSON representation and verify all values survive | Tests/OpsTests/DryContextTests.swift:155 |
| test0101 | `test0101_dry_context_clone_is_independent` | TEST0101: Clone a DryContext and verify the clone is independent (mutations don't propagate) | Tests/OpsTests/DryContextTests.swift:189 |
| test0102 | `test0102_dry_context_keys` | TEST0102: Verify DryContext::keys() returns all inserted keys | Tests/OpsTests/DryContextTests.swift:198 |
| test0103 | `test0103_wet_context_keys` | TEST0103: Verify WetContext::keys() returns all inserted reference keys | Tests/OpsTests/WetContextTests.swift:74 |
| test0104 | `test0104_op_error_display_execution_failed` | TEST0104: Verify OpError.executionFailed displays with the correct message format | Tests/OpsTests/OpErrorTests.swift:7 |
| test0105 | `test0105_op_error_display_timeout` | TEST0105: Verify OpError.timeout displays with the correct timeout_ms value | Tests/OpsTests/OpErrorTests.swift:13 |
| test0106 | `test0106_op_error_display_context` | TEST0106: Verify OpError.context displays with the correct message format | Tests/OpsTests/OpErrorTests.swift:19 |
| test0107 | `test0107_op_error_display_aborted` | TEST0107: Verify OpError.aborted displays with the correct message format | Tests/OpsTests/OpErrorTests.swift:25 |
| test0108 | `test0108_op_error_copy_execution_failed` | TEST0108: Clone (copy) an OpError.executionFailed and verify the copy is identical | Tests/OpsTests/OpErrorTests.swift:31 |
| test0109 | `test0109_op_error_copy_timeout` | TEST0109: Copy OpError.timeout and verify timeoutMs is preserved | Tests/OpsTests/OpErrorTests.swift:44 |
| test0110 | `test0110_op_error_other_holds_error` | TEST0110: Verify OpError.other holds the wrapped error's description | Tests/OpsTests/OpErrorTests.swift:55 |
| test0111 | `test0111_op_error_from_json_error` | TEST0111: Convert a JSON decoding error into OpError via wrapping | Tests/OpsTests/OpErrorTests.swift:65 |
| test0112 | `test0112_output_only_still_validates_references` | TEST0112: Verify ValidatingWrapper.outputOnly validates references even when input validation is disabled | Tests/OpsTests/ValidatingWrapperTests.swift:210 |
| test0113 | `test0113_loop_op_break_terminates_loop` | TEST0113: Run a LoopOp where an op sets the break flag via context and verify the loop terminates early | Tests/OpsTests/LoopOpTests.swift:177 |
| test0114 | `test0114_loop_op_continue_on_error_skips_failed_iterations` | TEST0114: Run LoopOp with continueOnError where an op fails and verify the loop continues | Tests/OpsTests/LoopOpTests.swift:204 |
| test0115 | `test0115_loop_op_with_no_ops_produces_no_results` | TEST0115: Run an empty LoopOp with a non-zero limit and verify it produces no results | Tests/OpsTests/LoopOpTests.swift:333 |
---

*Generated from Swift/ObjC source tree*
*Total tests: 105*
*Total numbered tests: 105*
*Total unnumbered tests: 0*
*Total numbered tests missing descriptions: 0*
*Total numbering mismatches: 0*
