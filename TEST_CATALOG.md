# Swift/ObjC Test Catalog

**Total Tests:** 105

**Numbered Tests:** 0

**Unnumbered Tests:** 105

**Numbered Tests Missing Descriptions:** 0

**Numbering Mismatches:** 105

All numbered test numbers are unique.

This catalog lists all tests in the Swift/ObjC codebase.

| Test # | Function Name | Description | File |
|--------|---------------|-------------|------|
| | | | |
| unnumbered | `test_001_op_execution` | TEST001: Run Op::perform and verify the returned value matches what the op was configured with | Tests/OpsTests/OpTests.swift:14 |
| unnumbered | `test_002_op_with_contexts` | TEST002: Verify Op reads from DryContext and produces a formatted result using that data | Tests/OpsTests/OpTests.swift:23 |
| unnumbered | `test_003_op_default_rollback` | TEST003: Confirm that the default rollback implementation is a no-op that always succeeds | Tests/OpsTests/OpTests.swift:40 |
| unnumbered | `test_004_op_custom_rollback` | TEST004: Verify a custom rollback implementation is called and sets the rolled_back flag | Tests/OpsTests/OpTests.swift:53 |
| unnumbered | `test_005_perform_with_auto_logging` | TEST005: Confirm the perform() utility wraps an op with automatic logging and returns its result | Tests/OpsTests/OpsUtilTests.swift:13 |
| unnumbered | `test_006_caller_trigger_name` | TEST006: Verify callerTriggerName() returns a string containing "::" | Tests/OpsTests/OpsUtilTests.swift:21 |
| unnumbered | `test_007_wrap_nested_op_exception` | TEST007: Confirm wrapNestedOpException wraps an error with the op name in the message | Tests/OpsTests/OpsUtilTests.swift:28 |
| unnumbered | `test_008_wrap_runtime_exception` | TEST008: Verify wrapRuntimeException converts a standard error into an OpError.executionFailed | Tests/OpsTests/OpsUtilTests.swift:40 |
| unnumbered | `test_009_dry_context_basic_operations` | TEST009: Insert typed values into DryContext and verify get/contains work correctly | Tests/OpsTests/DryContextTests.swift:7 |
| unnumbered | `test_010_dry_context_builder` | TEST010: Build a DryContext with chained with-value calls and verify all values are stored | Tests/OpsTests/DryContextTests.swift:19 |
| unnumbered | `test_011_wet_context_basic_operations` | TEST011: Insert a reference into WetContext and retrieve it by type via getRef | Tests/OpsTests/WetContextTests.swift:7 |
| unnumbered | `test_012_wet_context_builder` | TEST012: Build a WetContext with chained withRef calls and verify contains for each key | Tests/OpsTests/WetContextTests.swift:22 |
| unnumbered | `test_013_required_values` | TEST013: Confirm getRequired succeeds for present keys and returns an error for missing keys | Tests/OpsTests/DryContextTests.swift:29 |
| unnumbered | `test_014_context_merge` | TEST014: Merge two DryContexts and verify values from both are accessible in the target | Tests/OpsTests/DryContextTests.swift:37 |
| unnumbered | `test_015_dry_context_type_mismatch_error` | TEST015: Verify getRequired returns a Type mismatch error when the stored type doesn't match | Tests/OpsTests/DryContextTests.swift:46 |
| unnumbered | `test_016_wet_context_type_mismatch_error` | TEST016: Verify WetContext getRequired returns a Type mismatch error when the stored ref type differs | Tests/OpsTests/WetContextTests.swift:35 |
| unnumbered | `test_017_control_flags` | TEST017: Set and clear abort flags on DryContext and verify isAborted and abortReason reflect state | Tests/OpsTests/DryContextTests.swift:67 |
| unnumbered | `test_018_control_flags_merge` | TEST018: Merge contexts with abort flags and confirm the target inherits the abort state correctly | Tests/OpsTests/DryContextTests.swift:83 |
| unnumbered | `test_019_get_or_insert_with` | TEST019: Verify getOrInsert inserts when missing and returns existing without calling factory | Tests/OpsTests/DryContextTests.swift:102 |
| unnumbered | `test_020_get_or_compute_with` | TEST020: Verify getOrCompute computes and stores a value using context data | Tests/OpsTests/DryContextTests.swift:119 |
| unnumbered | `test_021_metadata_builder` | TEST021: Build OpMetadata with name, description, and schemas and verify all fields are populated | Tests/OpsTests/OpMetadataTests.swift:7 |
| unnumbered | `test_022_trigger_fuse` | TEST022: Construct a TriggerFuse with data and verify the trigger name and dry context values | Tests/OpsTests/OpMetadataTests.swift:25 |
| unnumbered | `test_023_basic_validation` | TEST023: Validate a DryContext against an input schema and confirm valid/invalid reports | Tests/OpsTests/OpMetadataTests.swift:36 |
| unnumbered | `test_024_simple_flat_outline` | TEST024: Build a flat ListingOutline with depth-0 entries and verify maxDepth, levels, and flatten count | Tests/OpsTests/StructuredQueriesTests.swift:7 |
| unnumbered | `test_025_hierarchical_outline` | TEST025: Build a two-level outline with chapters and sections and verify depth, level counts, and flatten | Tests/OpsTests/StructuredQueriesTests.swift:22 |
| unnumbered | `test_026_complex_part_based_outline` | TEST026: Build a three-level part/chapter/section outline and verify depth and per-level entry counts | Tests/OpsTests/StructuredQueriesTests.swift:43 |
| unnumbered | `test_027_flatten_preserves_hierarchy` | TEST027: Flatten a nested outline and verify each entry's path reflects its ancestry correctly | Tests/OpsTests/StructuredQueriesTests.swift:73 |
| unnumbered | `test_028_schema_generation` | TEST028: Call generateOutlineSchema and verify the returned dictionary contains all required definitions | Tests/OpsTests/StructuredQueriesTests.swift:90 |
| unnumbered | `test_029_logging_wrapper_success` | TEST029: Wrap a successful op in LoggingWrapper and verify it passes through the result unchanged | Tests/OpsTests/LoggingWrapperTests.swift:27 |
| unnumbered | `test_030_logging_wrapper_failure` | TEST030: Wrap a failing op in LoggingWrapper and verify the error includes the op name context | Tests/OpsTests/LoggingWrapperTests.swift:36 |
| unnumbered | `test_031_context_aware_logger` | TEST031: Use createContextAwareLogger helper and verify the wrapped op returns its result | Tests/OpsTests/LoggingWrapperTests.swift:51 |
| unnumbered | `test_032_ansi_color_constants` | TEST032: Verify ANSI color escape code constants have the expected ANSI sequence values | Tests/OpsTests/LoggingWrapperTests.swift:60 |
| unnumbered | `test_033_timeout_wrapper_success` | TEST033: Wrap a fast op in TimeBoundWrapper and confirm it completes before the timeout | Tests/OpsTests/TimeBoundWrapperTests.swift:43 |
| unnumbered | `test_034_timeout_wrapper_timeout` | TEST034: Wrap a slow op in TimeBoundWrapper with a short timeout and verify a Timeout error is returned | Tests/OpsTests/TimeBoundWrapperTests.swift:52 |
| unnumbered | `test_035_timeout_wrapper_with_name` | TEST035: Create a named TimeBoundWrapper and verify the op succeeds and returns the expected value | Tests/OpsTests/TimeBoundWrapperTests.swift:67 |
| unnumbered | `test_036_caller_name_wrapper` | TEST036: Use createTimeoutWrapperWithCallerName helper and verify the op result is returned | Tests/OpsTests/TimeBoundWrapperTests.swift:76 |
| unnumbered | `test_037_logged_timeout_wrapper` | TEST037: Use createLoggedTimeoutWrapper to compose logging and timeout wrappers and verify success | Tests/OpsTests/TimeBoundWrapperTests.swift:85 |
| unnumbered | `test_038_valid_input_output` | TEST038: Run ValidatingWrapper with a valid input and verify the op executes and returns the result | Tests/OpsTests/ValidatingWrapperTests.swift:34 |
| unnumbered | `test_039_invalid_input_missing_required` | TEST039: Run ValidatingWrapper without a required input field and verify a Context validation error | Tests/OpsTests/ValidatingWrapperTests.swift:44 |
| unnumbered | `test_040_invalid_input_out_of_range` | TEST040: Run ValidatingWrapper with an input exceeding the schema maximum and verify a validation error | Tests/OpsTests/ValidatingWrapperTests.swift:59 |
| unnumbered | `test_041_input_only_validation` | TEST041: Use ValidatingWrapper.inputOnly and confirm input is validated while output is not | Tests/OpsTests/ValidatingWrapperTests.swift:75 |
| unnumbered | `test_042_output_only_validation` | TEST042: Use ValidatingWrapper.outputOnly and confirm output is validated while input is not | Tests/OpsTests/ValidatingWrapperTests.swift:100 |
| unnumbered | `test_043_no_schema_validation` | TEST043: Wrap an op with no schemas in ValidatingWrapper and confirm it still succeeds | Tests/OpsTests/ValidatingWrapperTests.swift:124 |
| unnumbered | `test_044_metadata_transparency` | TEST044: Verify ValidatingWrapper.metadata() delegates to the inner op's metadata unchanged | Tests/OpsTests/ValidatingWrapperTests.swift:138 |
| unnumbered | `test_045_reference_validation` | TEST045: Verify ValidatingWrapper checks reference_schema and rejects when required refs are missing | Tests/OpsTests/ValidatingWrapperTests.swift:148 |
| unnumbered | `test_046_no_reference_schema` | TEST046: Wrap an op with no reference schema in ValidatingWrapper and confirm it succeeds | Tests/OpsTests/ValidatingWrapperTests.swift:196 |
| unnumbered | `test_047_batch_metadata_with_data_flow` | TEST047: Build BatchMetadata from producer/consumer ops and verify only external inputs are required | Tests/OpsTests/BatchMetadataTests.swift:7 |
| unnumbered | `test_048_reference_schema_merging` | TEST048: Build BatchMetadata from two ops with different reference schemas and verify union of required refs | Tests/OpsTests/BatchMetadataTests.swift:64 |
| unnumbered | `test_049_batch_op_success` | TEST049: Run BatchOp with two succeeding ops and verify results contain both values in order | Tests/OpsTests/BatchOpTests.swift:18 |
| unnumbered | `test_050_batch_op_failure` | TEST050: Run BatchOp where the second op fails and verify the batch returns an error | Tests/OpsTests/BatchOpTests.swift:28 |
| unnumbered | `test_051_batch_op_returns_all_results` | TEST051: Run BatchOp with two ops and verify both result values are present in order | Tests/OpsTests/BatchOpTests.swift:42 |
| unnumbered | `test_052_batch_metadata_data_flow` | TEST052: Verify BatchOp metadata correctly identifies only the externally-required input fields | Tests/OpsTests/BatchOpTests.swift:302 |
| unnumbered | `test_053_batch_reference_schema_merging` | TEST053: Verify BatchOp merges reference schemas from all ops into a unified set of required refs | Tests/OpsTests/BatchOpTests.swift:54 |
| unnumbered | `test_054_batch_rollback_on_failure` | TEST054: Run BatchOp where the third op fails and verify rollback is called on the first two but not the third | Tests/OpsTests/BatchOpTests.swift:96 |
| unnumbered | `test_055_batch_rollback_order` | TEST055: Run BatchOp where the last op fails and verify rollback occurs in reverse (LIFO) order | Tests/OpsTests/BatchOpTests.swift:159 |
| unnumbered | `test_056_batch_rollback_on_failure_partial` | TEST056: Run BatchOp where one op fails and verify rollback is triggered for succeeded ops | Tests/OpsTests/BatchOpTests.swift:194 |
| unnumbered | `test_057_abort_without_reason` | TEST057: Invoke the abort pattern without a reason and verify the context is aborted with no reason string | Tests/OpsTests/ControlFlowTests.swift:54 |
| unnumbered | `test_058_abort_with_reason` | TEST058: Invoke the abort pattern with a reason string and verify abort_reason matches | Tests/OpsTests/ControlFlowTests.swift:72 |
| unnumbered | `test_059_continue_loop_via_context_flag` | TEST059: Signal continue from inside an op using the context flag and verify subsequent ops are skipped | Tests/OpsTests/ControlFlowTests.swift:90 |
| unnumbered | `test_060_check_abort_pattern` | TEST060: Use check_abort pattern to short-circuit when the abort flag is already set in context | Tests/OpsTests/ControlFlowTests.swift:119 |
| unnumbered | `test_061_batch_op_with_abort` | TEST061: Run a BatchOp where the second op aborts and verify the batch stops and propagates the abort | Tests/OpsTests/ControlFlowTests.swift:138 |
| unnumbered | `test_062_batch_op_with_pre_existing_abort` | TEST062: Start a BatchOp with an abort flag already set and verify it immediately returns Aborted | Tests/OpsTests/ControlFlowTests.swift:159 |
| unnumbered | `test_063_loop_op_with_continue` | TEST063: Run a LoopOp where an op signals continue and verify subsequent ops in the iteration are skipped | Tests/OpsTests/ControlFlowTests.swift:180 |
| unnumbered | `test_064_loop_op_with_abort` | TEST064: Run a LoopOp where an op aborts mid-loop and verify the loop terminates with the abort error | Tests/OpsTests/ControlFlowTests.swift:213 |
| unnumbered | `test_065_loop_op_with_pre_existing_abort` | TEST065: Start a LoopOp with an abort flag already set and verify it immediately returns Aborted | Tests/OpsTests/ControlFlowTests.swift:237 |
| unnumbered | `test_066_complex_control_flow_scenario` | TEST066: Nest a batch with a continue op inside a loop and verify results across all iterations | Tests/OpsTests/ControlFlowTests.swift:258 |
| unnumbered | `test_067_loop_op_basic` | TEST067: Run a LoopOp for 3 iterations with 2 ops each and verify all 6 results in order | Tests/OpsTests/LoopOpTests.swift:22 |
| unnumbered | `test_068_loop_op_with_counter_access` | TEST068: Run a LoopOp where each op reads the loop counter and verify values are 0, 1, 2 | Tests/OpsTests/LoopOpTests.swift:32 |
| unnumbered | `test_069_loop_op_existing_counter` | TEST069: Start a LoopOp with a pre-initialized counter and verify it only executes remaining iterations | Tests/OpsTests/LoopOpTests.swift:41 |
| unnumbered | `test_070_loop_op_zero_limit` | TEST070: Run a LoopOp with a zero iteration limit and verify no ops are executed | Tests/OpsTests/LoopOpTests.swift:52 |
| unnumbered | `test_071_loop_op_builder_pattern` | TEST071: Build a LoopOp with addOp chaining and verify all added ops run across all iterations | Tests/OpsTests/LoopOpTests.swift:61 |
| unnumbered | `test_072_loop_op_rollback_on_iteration_failure` | TEST072: Run a LoopOp where the third op fails and verify succeeded ops are rolled back in reverse order | Tests/OpsTests/LoopOpTests.swift:72 |
| unnumbered | `test_073_loop_op_rollback_order_within_iteration` | TEST073: Run a LoopOp where the last op fails and verify rollback occurs in LIFO order within the iteration | Tests/OpsTests/LoopOpTests.swift:103 |
| unnumbered | `test_074_loop_op_successful_iterations_not_rolled_back` | TEST074: Run a LoopOp that fails on iteration 2 and verify previously completed iterations are not rolled back | Tests/OpsTests/LoopOpTests.swift:234 |
| unnumbered | `test_075_loop_op_mixed_iteration_with_rollback` | TEST075: Run a LoopOp where op2 fails on iteration 1 and verify only op1 from that iteration is rolled back | Tests/OpsTests/LoopOpTests.swift:280 |
| unnumbered | `test_076_loop_op_continue_on_error` | TEST076: Run a LoopOp configured to continue on error and verify subsequent iterations still execute | Tests/OpsTests/LoopOpTests.swift:136 |
| unnumbered | `test_077_dry_put_and_get` | TEST077: Use dryPut and dryGet to store and retrieve a typed value by variable name | Tests/OpsTests/ContextHelpersTests.swift:7 |
| unnumbered | `test_078_dry_require` | TEST078: Use dryRequire to retrieve a required value and verify error when key is missing | Tests/OpsTests/ContextHelpersTests.swift:16 |
| unnumbered | `test_079_dry_result` | TEST079: Use dryResult to store a final result and verify it is stored under both "result" and op name | Tests/OpsTests/ContextHelpersTests.swift:28 |
| unnumbered | `test_080_wet_put_ref_and_require_ref` | TEST080: Use wetPutRef and wetRequireRef to store and retrieve a service reference | Tests/OpsTests/ContextHelpersTests.swift:38 |
| unnumbered | `test_081_wet_put_ref_arc_style` | TEST081: Store a service via wetPutRef and retrieve it via wetRequireRef | Tests/OpsTests/ContextHelpersTests.swift:52 |
| unnumbered | `test_082_helpers_in_op` | TEST082: Run a full op that uses dryRequire and wetRequireRef helpers internally and verify the output | Tests/OpsTests/ContextHelpersTests.swift:66 |
| unnumbered | `test_093_batch_len_and_is_empty` | TEST093: Call BatchOp.count and isEmpty on empty and non-empty batches | Tests/OpsTests/BatchOpTests.swift:226 |
| unnumbered | `test_094_batch_add_op` | TEST094: Use addOp to dynamically add an op and verify it is executed | Tests/OpsTests/BatchOpTests.swift:366 |
| unnumbered | `test_095_batch_continue_on_error` | TEST095: Run BatchOp with continueOnError and verify it collects results past failures | Tests/OpsTests/BatchOpTests.swift:237 |
| unnumbered | `test_096_empty_batch_returns_empty` | TEST096: Run an empty BatchOp and verify it returns an empty result array | Tests/OpsTests/BatchOpTests.swift:250 |
| unnumbered | `test_097_nested_batch_rollback` | TEST097: Verify nested BatchOp rollback propagates correctly when outer batch fails | Tests/OpsTests/BatchOpTests.swift:258 |
| unnumbered | `test_098_dry_context_merge_overwrites_keys` | TEST098: Merge two DryContexts where keys overlap and verify the merging context's values win | Tests/OpsTests/DryContextTests.swift:145 |
| unnumbered | `test_099_wet_context_merge` | TEST099: Merge two WetContexts and verify both sets of references are accessible in the target | Tests/OpsTests/WetContextTests.swift:58 |
| unnumbered | `test_100_dry_context_serde_roundtrip` | TEST100: Serialize and deserialize a DryContext JSON representation and verify all values survive | Tests/OpsTests/DryContextTests.swift:155 |
| unnumbered | `test_101_dry_context_clone_is_independent` | TEST101: Clone a DryContext and verify the clone is independent (mutations don't propagate) | Tests/OpsTests/DryContextTests.swift:189 |
| unnumbered | `test_102_dry_context_keys` | TEST102: Verify DryContext::keys() returns all inserted keys | Tests/OpsTests/DryContextTests.swift:198 |
| unnumbered | `test_103_wet_context_keys` | TEST103: Verify WetContext::keys() returns all inserted reference keys | Tests/OpsTests/WetContextTests.swift:74 |
| unnumbered | `test_104_op_error_display_execution_failed` | TEST104: Verify OpError.executionFailed displays with the correct message format | Tests/OpsTests/OpErrorTests.swift:7 |
| unnumbered | `test_105_op_error_display_timeout` | TEST105: Verify OpError.timeout displays with the correct timeout_ms value | Tests/OpsTests/OpErrorTests.swift:13 |
| unnumbered | `test_106_op_error_display_context` | TEST106: Verify OpError.context displays with the correct message format | Tests/OpsTests/OpErrorTests.swift:19 |
| unnumbered | `test_107_op_error_display_aborted` | TEST107: Verify OpError.aborted displays with the correct message format | Tests/OpsTests/OpErrorTests.swift:25 |
| unnumbered | `test_108_op_error_copy_execution_failed` | TEST108: Clone (copy) an OpError.executionFailed and verify the copy is identical | Tests/OpsTests/OpErrorTests.swift:31 |
| unnumbered | `test_109_op_error_copy_timeout` | TEST109: Copy OpError.timeout and verify timeoutMs is preserved | Tests/OpsTests/OpErrorTests.swift:44 |
| unnumbered | `test_110_op_error_other_holds_error` | TEST110: Verify OpError.other holds the wrapped error's description | Tests/OpsTests/OpErrorTests.swift:55 |
| unnumbered | `test_111_op_error_from_json_error` | TEST111: Convert a JSON decoding error into OpError via wrapping | Tests/OpsTests/OpErrorTests.swift:65 |
| unnumbered | `test_112_output_only_still_validates_references` | TEST112: Verify ValidatingWrapper.outputOnly validates references even when input validation is disabled | Tests/OpsTests/ValidatingWrapperTests.swift:210 |
| unnumbered | `test_113_loop_op_break_terminates_loop` | TEST113: Run a LoopOp where an op sets the break flag via context and verify the loop terminates early | Tests/OpsTests/LoopOpTests.swift:177 |
| unnumbered | `test_114_loop_op_continue_on_error_skips_failed_iterations` | TEST114: Run LoopOp with continueOnError where an op fails and verify the loop continues | Tests/OpsTests/LoopOpTests.swift:204 |
| unnumbered | `test_115_loop_op_with_no_ops_produces_no_results` | TEST115: Run an empty LoopOp with a non-zero limit and verify it produces no results | Tests/OpsTests/LoopOpTests.swift:333 |
---

## Unnumbered Tests

The following tests are cataloged but do not currently participate in numeric test indexing.

- `test_001_op_execution` — Tests/OpsTests/OpTests.swift:14
- `test_002_op_with_contexts` — Tests/OpsTests/OpTests.swift:23
- `test_003_op_default_rollback` — Tests/OpsTests/OpTests.swift:40
- `test_004_op_custom_rollback` — Tests/OpsTests/OpTests.swift:53
- `test_005_perform_with_auto_logging` — Tests/OpsTests/OpsUtilTests.swift:13
- `test_006_caller_trigger_name` — Tests/OpsTests/OpsUtilTests.swift:21
- `test_007_wrap_nested_op_exception` — Tests/OpsTests/OpsUtilTests.swift:28
- `test_008_wrap_runtime_exception` — Tests/OpsTests/OpsUtilTests.swift:40
- `test_009_dry_context_basic_operations` — Tests/OpsTests/DryContextTests.swift:7
- `test_010_dry_context_builder` — Tests/OpsTests/DryContextTests.swift:19
- `test_011_wet_context_basic_operations` — Tests/OpsTests/WetContextTests.swift:7
- `test_012_wet_context_builder` — Tests/OpsTests/WetContextTests.swift:22
- `test_013_required_values` — Tests/OpsTests/DryContextTests.swift:29
- `test_014_context_merge` — Tests/OpsTests/DryContextTests.swift:37
- `test_015_dry_context_type_mismatch_error` — Tests/OpsTests/DryContextTests.swift:46
- `test_016_wet_context_type_mismatch_error` — Tests/OpsTests/WetContextTests.swift:35
- `test_017_control_flags` — Tests/OpsTests/DryContextTests.swift:67
- `test_018_control_flags_merge` — Tests/OpsTests/DryContextTests.swift:83
- `test_019_get_or_insert_with` — Tests/OpsTests/DryContextTests.swift:102
- `test_020_get_or_compute_with` — Tests/OpsTests/DryContextTests.swift:119
- `test_021_metadata_builder` — Tests/OpsTests/OpMetadataTests.swift:7
- `test_022_trigger_fuse` — Tests/OpsTests/OpMetadataTests.swift:25
- `test_023_basic_validation` — Tests/OpsTests/OpMetadataTests.swift:36
- `test_024_simple_flat_outline` — Tests/OpsTests/StructuredQueriesTests.swift:7
- `test_025_hierarchical_outline` — Tests/OpsTests/StructuredQueriesTests.swift:22
- `test_026_complex_part_based_outline` — Tests/OpsTests/StructuredQueriesTests.swift:43
- `test_027_flatten_preserves_hierarchy` — Tests/OpsTests/StructuredQueriesTests.swift:73
- `test_028_schema_generation` — Tests/OpsTests/StructuredQueriesTests.swift:90
- `test_029_logging_wrapper_success` — Tests/OpsTests/LoggingWrapperTests.swift:27
- `test_030_logging_wrapper_failure` — Tests/OpsTests/LoggingWrapperTests.swift:36
- `test_031_context_aware_logger` — Tests/OpsTests/LoggingWrapperTests.swift:51
- `test_032_ansi_color_constants` — Tests/OpsTests/LoggingWrapperTests.swift:60
- `test_033_timeout_wrapper_success` — Tests/OpsTests/TimeBoundWrapperTests.swift:43
- `test_034_timeout_wrapper_timeout` — Tests/OpsTests/TimeBoundWrapperTests.swift:52
- `test_035_timeout_wrapper_with_name` — Tests/OpsTests/TimeBoundWrapperTests.swift:67
- `test_036_caller_name_wrapper` — Tests/OpsTests/TimeBoundWrapperTests.swift:76
- `test_037_logged_timeout_wrapper` — Tests/OpsTests/TimeBoundWrapperTests.swift:85
- `test_038_valid_input_output` — Tests/OpsTests/ValidatingWrapperTests.swift:34
- `test_039_invalid_input_missing_required` — Tests/OpsTests/ValidatingWrapperTests.swift:44
- `test_040_invalid_input_out_of_range` — Tests/OpsTests/ValidatingWrapperTests.swift:59
- `test_041_input_only_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:75
- `test_042_output_only_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:100
- `test_043_no_schema_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:124
- `test_044_metadata_transparency` — Tests/OpsTests/ValidatingWrapperTests.swift:138
- `test_045_reference_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:148
- `test_046_no_reference_schema` — Tests/OpsTests/ValidatingWrapperTests.swift:196
- `test_047_batch_metadata_with_data_flow` — Tests/OpsTests/BatchMetadataTests.swift:7
- `test_048_reference_schema_merging` — Tests/OpsTests/BatchMetadataTests.swift:64
- `test_049_batch_op_success` — Tests/OpsTests/BatchOpTests.swift:18
- `test_050_batch_op_failure` — Tests/OpsTests/BatchOpTests.swift:28
- `test_051_batch_op_returns_all_results` — Tests/OpsTests/BatchOpTests.swift:42
- `test_052_batch_metadata_data_flow` — Tests/OpsTests/BatchOpTests.swift:302
- `test_053_batch_reference_schema_merging` — Tests/OpsTests/BatchOpTests.swift:54
- `test_054_batch_rollback_on_failure` — Tests/OpsTests/BatchOpTests.swift:96
- `test_055_batch_rollback_order` — Tests/OpsTests/BatchOpTests.swift:159
- `test_056_batch_rollback_on_failure_partial` — Tests/OpsTests/BatchOpTests.swift:194
- `test_057_abort_without_reason` — Tests/OpsTests/ControlFlowTests.swift:54
- `test_058_abort_with_reason` — Tests/OpsTests/ControlFlowTests.swift:72
- `test_059_continue_loop_via_context_flag` — Tests/OpsTests/ControlFlowTests.swift:90
- `test_060_check_abort_pattern` — Tests/OpsTests/ControlFlowTests.swift:119
- `test_061_batch_op_with_abort` — Tests/OpsTests/ControlFlowTests.swift:138
- `test_062_batch_op_with_pre_existing_abort` — Tests/OpsTests/ControlFlowTests.swift:159
- `test_063_loop_op_with_continue` — Tests/OpsTests/ControlFlowTests.swift:180
- `test_064_loop_op_with_abort` — Tests/OpsTests/ControlFlowTests.swift:213
- `test_065_loop_op_with_pre_existing_abort` — Tests/OpsTests/ControlFlowTests.swift:237
- `test_066_complex_control_flow_scenario` — Tests/OpsTests/ControlFlowTests.swift:258
- `test_067_loop_op_basic` — Tests/OpsTests/LoopOpTests.swift:22
- `test_068_loop_op_with_counter_access` — Tests/OpsTests/LoopOpTests.swift:32
- `test_069_loop_op_existing_counter` — Tests/OpsTests/LoopOpTests.swift:41
- `test_070_loop_op_zero_limit` — Tests/OpsTests/LoopOpTests.swift:52
- `test_071_loop_op_builder_pattern` — Tests/OpsTests/LoopOpTests.swift:61
- `test_072_loop_op_rollback_on_iteration_failure` — Tests/OpsTests/LoopOpTests.swift:72
- `test_073_loop_op_rollback_order_within_iteration` — Tests/OpsTests/LoopOpTests.swift:103
- `test_074_loop_op_successful_iterations_not_rolled_back` — Tests/OpsTests/LoopOpTests.swift:234
- `test_075_loop_op_mixed_iteration_with_rollback` — Tests/OpsTests/LoopOpTests.swift:280
- `test_076_loop_op_continue_on_error` — Tests/OpsTests/LoopOpTests.swift:136
- `test_077_dry_put_and_get` — Tests/OpsTests/ContextHelpersTests.swift:7
- `test_078_dry_require` — Tests/OpsTests/ContextHelpersTests.swift:16
- `test_079_dry_result` — Tests/OpsTests/ContextHelpersTests.swift:28
- `test_080_wet_put_ref_and_require_ref` — Tests/OpsTests/ContextHelpersTests.swift:38
- `test_081_wet_put_ref_arc_style` — Tests/OpsTests/ContextHelpersTests.swift:52
- `test_082_helpers_in_op` — Tests/OpsTests/ContextHelpersTests.swift:66
- `test_093_batch_len_and_is_empty` — Tests/OpsTests/BatchOpTests.swift:226
- `test_094_batch_add_op` — Tests/OpsTests/BatchOpTests.swift:366
- `test_095_batch_continue_on_error` — Tests/OpsTests/BatchOpTests.swift:237
- `test_096_empty_batch_returns_empty` — Tests/OpsTests/BatchOpTests.swift:250
- `test_097_nested_batch_rollback` — Tests/OpsTests/BatchOpTests.swift:258
- `test_098_dry_context_merge_overwrites_keys` — Tests/OpsTests/DryContextTests.swift:145
- `test_099_wet_context_merge` — Tests/OpsTests/WetContextTests.swift:58
- `test_100_dry_context_serde_roundtrip` — Tests/OpsTests/DryContextTests.swift:155
- `test_101_dry_context_clone_is_independent` — Tests/OpsTests/DryContextTests.swift:189
- `test_102_dry_context_keys` — Tests/OpsTests/DryContextTests.swift:198
- `test_103_wet_context_keys` — Tests/OpsTests/WetContextTests.swift:74
- `test_104_op_error_display_execution_failed` — Tests/OpsTests/OpErrorTests.swift:7
- `test_105_op_error_display_timeout` — Tests/OpsTests/OpErrorTests.swift:13
- `test_106_op_error_display_context` — Tests/OpsTests/OpErrorTests.swift:19
- `test_107_op_error_display_aborted` — Tests/OpsTests/OpErrorTests.swift:25
- `test_108_op_error_copy_execution_failed` — Tests/OpsTests/OpErrorTests.swift:31
- `test_109_op_error_copy_timeout` — Tests/OpsTests/OpErrorTests.swift:44
- `test_110_op_error_other_holds_error` — Tests/OpsTests/OpErrorTests.swift:55
- `test_111_op_error_from_json_error` — Tests/OpsTests/OpErrorTests.swift:65
- `test_112_output_only_still_validates_references` — Tests/OpsTests/ValidatingWrapperTests.swift:210
- `test_113_loop_op_break_terminates_loop` — Tests/OpsTests/LoopOpTests.swift:177
- `test_114_loop_op_continue_on_error_skips_failed_iterations` — Tests/OpsTests/LoopOpTests.swift:204
- `test_115_loop_op_with_no_ops_produces_no_results` — Tests/OpsTests/LoopOpTests.swift:333

---

## Numbering Mismatches

These tests have a numbering disagreement between the function name and the authoritative immediate TEST comment/docstring above the test. This is reported explicitly so comment sync does not silently overwrite a misnumbered test.

- `unnumbered` / `test001` / `test_001_op_execution` — Tests/OpsTests/OpTests.swift:14
- `unnumbered` / `test002` / `test_002_op_with_contexts` — Tests/OpsTests/OpTests.swift:23
- `unnumbered` / `test003` / `test_003_op_default_rollback` — Tests/OpsTests/OpTests.swift:40
- `unnumbered` / `test004` / `test_004_op_custom_rollback` — Tests/OpsTests/OpTests.swift:53
- `unnumbered` / `test005` / `test_005_perform_with_auto_logging` — Tests/OpsTests/OpsUtilTests.swift:13
- `unnumbered` / `test006` / `test_006_caller_trigger_name` — Tests/OpsTests/OpsUtilTests.swift:21
- `unnumbered` / `test007` / `test_007_wrap_nested_op_exception` — Tests/OpsTests/OpsUtilTests.swift:28
- `unnumbered` / `test008` / `test_008_wrap_runtime_exception` — Tests/OpsTests/OpsUtilTests.swift:40
- `unnumbered` / `test009` / `test_009_dry_context_basic_operations` — Tests/OpsTests/DryContextTests.swift:7
- `unnumbered` / `test010` / `test_010_dry_context_builder` — Tests/OpsTests/DryContextTests.swift:19
- `unnumbered` / `test011` / `test_011_wet_context_basic_operations` — Tests/OpsTests/WetContextTests.swift:7
- `unnumbered` / `test012` / `test_012_wet_context_builder` — Tests/OpsTests/WetContextTests.swift:22
- `unnumbered` / `test013` / `test_013_required_values` — Tests/OpsTests/DryContextTests.swift:29
- `unnumbered` / `test014` / `test_014_context_merge` — Tests/OpsTests/DryContextTests.swift:37
- `unnumbered` / `test015` / `test_015_dry_context_type_mismatch_error` — Tests/OpsTests/DryContextTests.swift:46
- `unnumbered` / `test016` / `test_016_wet_context_type_mismatch_error` — Tests/OpsTests/WetContextTests.swift:35
- `unnumbered` / `test017` / `test_017_control_flags` — Tests/OpsTests/DryContextTests.swift:67
- `unnumbered` / `test018` / `test_018_control_flags_merge` — Tests/OpsTests/DryContextTests.swift:83
- `unnumbered` / `test019` / `test_019_get_or_insert_with` — Tests/OpsTests/DryContextTests.swift:102
- `unnumbered` / `test020` / `test_020_get_or_compute_with` — Tests/OpsTests/DryContextTests.swift:119
- `unnumbered` / `test021` / `test_021_metadata_builder` — Tests/OpsTests/OpMetadataTests.swift:7
- `unnumbered` / `test022` / `test_022_trigger_fuse` — Tests/OpsTests/OpMetadataTests.swift:25
- `unnumbered` / `test023` / `test_023_basic_validation` — Tests/OpsTests/OpMetadataTests.swift:36
- `unnumbered` / `test024` / `test_024_simple_flat_outline` — Tests/OpsTests/StructuredQueriesTests.swift:7
- `unnumbered` / `test025` / `test_025_hierarchical_outline` — Tests/OpsTests/StructuredQueriesTests.swift:22
- `unnumbered` / `test026` / `test_026_complex_part_based_outline` — Tests/OpsTests/StructuredQueriesTests.swift:43
- `unnumbered` / `test027` / `test_027_flatten_preserves_hierarchy` — Tests/OpsTests/StructuredQueriesTests.swift:73
- `unnumbered` / `test028` / `test_028_schema_generation` — Tests/OpsTests/StructuredQueriesTests.swift:90
- `unnumbered` / `test029` / `test_029_logging_wrapper_success` — Tests/OpsTests/LoggingWrapperTests.swift:27
- `unnumbered` / `test030` / `test_030_logging_wrapper_failure` — Tests/OpsTests/LoggingWrapperTests.swift:36
- `unnumbered` / `test031` / `test_031_context_aware_logger` — Tests/OpsTests/LoggingWrapperTests.swift:51
- `unnumbered` / `test032` / `test_032_ansi_color_constants` — Tests/OpsTests/LoggingWrapperTests.swift:60
- `unnumbered` / `test033` / `test_033_timeout_wrapper_success` — Tests/OpsTests/TimeBoundWrapperTests.swift:43
- `unnumbered` / `test034` / `test_034_timeout_wrapper_timeout` — Tests/OpsTests/TimeBoundWrapperTests.swift:52
- `unnumbered` / `test035` / `test_035_timeout_wrapper_with_name` — Tests/OpsTests/TimeBoundWrapperTests.swift:67
- `unnumbered` / `test036` / `test_036_caller_name_wrapper` — Tests/OpsTests/TimeBoundWrapperTests.swift:76
- `unnumbered` / `test037` / `test_037_logged_timeout_wrapper` — Tests/OpsTests/TimeBoundWrapperTests.swift:85
- `unnumbered` / `test038` / `test_038_valid_input_output` — Tests/OpsTests/ValidatingWrapperTests.swift:34
- `unnumbered` / `test039` / `test_039_invalid_input_missing_required` — Tests/OpsTests/ValidatingWrapperTests.swift:44
- `unnumbered` / `test040` / `test_040_invalid_input_out_of_range` — Tests/OpsTests/ValidatingWrapperTests.swift:59
- `unnumbered` / `test041` / `test_041_input_only_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:75
- `unnumbered` / `test042` / `test_042_output_only_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:100
- `unnumbered` / `test043` / `test_043_no_schema_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:124
- `unnumbered` / `test044` / `test_044_metadata_transparency` — Tests/OpsTests/ValidatingWrapperTests.swift:138
- `unnumbered` / `test045` / `test_045_reference_validation` — Tests/OpsTests/ValidatingWrapperTests.swift:148
- `unnumbered` / `test046` / `test_046_no_reference_schema` — Tests/OpsTests/ValidatingWrapperTests.swift:196
- `unnumbered` / `test047` / `test_047_batch_metadata_with_data_flow` — Tests/OpsTests/BatchMetadataTests.swift:7
- `unnumbered` / `test048` / `test_048_reference_schema_merging` — Tests/OpsTests/BatchMetadataTests.swift:64
- `unnumbered` / `test049` / `test_049_batch_op_success` — Tests/OpsTests/BatchOpTests.swift:18
- `unnumbered` / `test050` / `test_050_batch_op_failure` — Tests/OpsTests/BatchOpTests.swift:28
- `unnumbered` / `test051` / `test_051_batch_op_returns_all_results` — Tests/OpsTests/BatchOpTests.swift:42
- `unnumbered` / `test052` / `test_052_batch_metadata_data_flow` — Tests/OpsTests/BatchOpTests.swift:302
- `unnumbered` / `test053` / `test_053_batch_reference_schema_merging` — Tests/OpsTests/BatchOpTests.swift:54
- `unnumbered` / `test054` / `test_054_batch_rollback_on_failure` — Tests/OpsTests/BatchOpTests.swift:96
- `unnumbered` / `test055` / `test_055_batch_rollback_order` — Tests/OpsTests/BatchOpTests.swift:159
- `unnumbered` / `test056` / `test_056_batch_rollback_on_failure_partial` — Tests/OpsTests/BatchOpTests.swift:194
- `unnumbered` / `test057` / `test_057_abort_without_reason` — Tests/OpsTests/ControlFlowTests.swift:54
- `unnumbered` / `test058` / `test_058_abort_with_reason` — Tests/OpsTests/ControlFlowTests.swift:72
- `unnumbered` / `test059` / `test_059_continue_loop_via_context_flag` — Tests/OpsTests/ControlFlowTests.swift:90
- `unnumbered` / `test060` / `test_060_check_abort_pattern` — Tests/OpsTests/ControlFlowTests.swift:119
- `unnumbered` / `test061` / `test_061_batch_op_with_abort` — Tests/OpsTests/ControlFlowTests.swift:138
- `unnumbered` / `test062` / `test_062_batch_op_with_pre_existing_abort` — Tests/OpsTests/ControlFlowTests.swift:159
- `unnumbered` / `test063` / `test_063_loop_op_with_continue` — Tests/OpsTests/ControlFlowTests.swift:180
- `unnumbered` / `test064` / `test_064_loop_op_with_abort` — Tests/OpsTests/ControlFlowTests.swift:213
- `unnumbered` / `test065` / `test_065_loop_op_with_pre_existing_abort` — Tests/OpsTests/ControlFlowTests.swift:237
- `unnumbered` / `test066` / `test_066_complex_control_flow_scenario` — Tests/OpsTests/ControlFlowTests.swift:258
- `unnumbered` / `test067` / `test_067_loop_op_basic` — Tests/OpsTests/LoopOpTests.swift:22
- `unnumbered` / `test068` / `test_068_loop_op_with_counter_access` — Tests/OpsTests/LoopOpTests.swift:32
- `unnumbered` / `test069` / `test_069_loop_op_existing_counter` — Tests/OpsTests/LoopOpTests.swift:41
- `unnumbered` / `test070` / `test_070_loop_op_zero_limit` — Tests/OpsTests/LoopOpTests.swift:52
- `unnumbered` / `test071` / `test_071_loop_op_builder_pattern` — Tests/OpsTests/LoopOpTests.swift:61
- `unnumbered` / `test072` / `test_072_loop_op_rollback_on_iteration_failure` — Tests/OpsTests/LoopOpTests.swift:72
- `unnumbered` / `test073` / `test_073_loop_op_rollback_order_within_iteration` — Tests/OpsTests/LoopOpTests.swift:103
- `unnumbered` / `test074` / `test_074_loop_op_successful_iterations_not_rolled_back` — Tests/OpsTests/LoopOpTests.swift:234
- `unnumbered` / `test075` / `test_075_loop_op_mixed_iteration_with_rollback` — Tests/OpsTests/LoopOpTests.swift:280
- `unnumbered` / `test076` / `test_076_loop_op_continue_on_error` — Tests/OpsTests/LoopOpTests.swift:136
- `unnumbered` / `test077` / `test_077_dry_put_and_get` — Tests/OpsTests/ContextHelpersTests.swift:7
- `unnumbered` / `test078` / `test_078_dry_require` — Tests/OpsTests/ContextHelpersTests.swift:16
- `unnumbered` / `test079` / `test_079_dry_result` — Tests/OpsTests/ContextHelpersTests.swift:28
- `unnumbered` / `test080` / `test_080_wet_put_ref_and_require_ref` — Tests/OpsTests/ContextHelpersTests.swift:38
- `unnumbered` / `test081` / `test_081_wet_put_ref_arc_style` — Tests/OpsTests/ContextHelpersTests.swift:52
- `unnumbered` / `test082` / `test_082_helpers_in_op` — Tests/OpsTests/ContextHelpersTests.swift:66
- `unnumbered` / `test093` / `test_093_batch_len_and_is_empty` — Tests/OpsTests/BatchOpTests.swift:226
- `unnumbered` / `test094` / `test_094_batch_add_op` — Tests/OpsTests/BatchOpTests.swift:366
- `unnumbered` / `test095` / `test_095_batch_continue_on_error` — Tests/OpsTests/BatchOpTests.swift:237
- `unnumbered` / `test096` / `test_096_empty_batch_returns_empty` — Tests/OpsTests/BatchOpTests.swift:250
- `unnumbered` / `test097` / `test_097_nested_batch_rollback` — Tests/OpsTests/BatchOpTests.swift:258
- `unnumbered` / `test098` / `test_098_dry_context_merge_overwrites_keys` — Tests/OpsTests/DryContextTests.swift:145
- `unnumbered` / `test099` / `test_099_wet_context_merge` — Tests/OpsTests/WetContextTests.swift:58
- `unnumbered` / `test100` / `test_100_dry_context_serde_roundtrip` — Tests/OpsTests/DryContextTests.swift:155
- `unnumbered` / `test101` / `test_101_dry_context_clone_is_independent` — Tests/OpsTests/DryContextTests.swift:189
- `unnumbered` / `test102` / `test_102_dry_context_keys` — Tests/OpsTests/DryContextTests.swift:198
- `unnumbered` / `test103` / `test_103_wet_context_keys` — Tests/OpsTests/WetContextTests.swift:74
- `unnumbered` / `test104` / `test_104_op_error_display_execution_failed` — Tests/OpsTests/OpErrorTests.swift:7
- `unnumbered` / `test105` / `test_105_op_error_display_timeout` — Tests/OpsTests/OpErrorTests.swift:13
- `unnumbered` / `test106` / `test_106_op_error_display_context` — Tests/OpsTests/OpErrorTests.swift:19
- `unnumbered` / `test107` / `test_107_op_error_display_aborted` — Tests/OpsTests/OpErrorTests.swift:25
- `unnumbered` / `test108` / `test_108_op_error_copy_execution_failed` — Tests/OpsTests/OpErrorTests.swift:31
- `unnumbered` / `test109` / `test_109_op_error_copy_timeout` — Tests/OpsTests/OpErrorTests.swift:44
- `unnumbered` / `test110` / `test_110_op_error_other_holds_error` — Tests/OpsTests/OpErrorTests.swift:55
- `unnumbered` / `test111` / `test_111_op_error_from_json_error` — Tests/OpsTests/OpErrorTests.swift:65
- `unnumbered` / `test112` / `test_112_output_only_still_validates_references` — Tests/OpsTests/ValidatingWrapperTests.swift:210
- `unnumbered` / `test113` / `test_113_loop_op_break_terminates_loop` — Tests/OpsTests/LoopOpTests.swift:177
- `unnumbered` / `test114` / `test_114_loop_op_continue_on_error_skips_failed_iterations` — Tests/OpsTests/LoopOpTests.swift:204
- `unnumbered` / `test115` / `test_115_loop_op_with_no_ops_produces_no_results` — Tests/OpsTests/LoopOpTests.swift:333

---

*Generated from Swift/ObjC source tree*
*Total tests: 105*
*Total numbered tests: 0*
*Total unnumbered tests: 105*
*Total numbered tests missing descriptions: 0*
*Total numbering mismatches: 105*
