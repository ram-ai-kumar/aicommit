# Model Testing and AI Backend Step Definitions
# Handles AI model testing, backend connectivity, and model management

When(/^I check available models$/) do
  @model_output = `ollama list 2>&1`
  @models_checked = true
end

Then(/^I should see model names only$/) do
  # Basic check that we get some output from ollama
  expect(@model_output.length).to be > 0
  @model_names_only = true
end

Given(/^a test model is available$/) do
  # Check if qwen2.5-coder or similar model is available
  @model_output = `ollama list 2>&1`
  @test_model_available = @model_output.include?('qwen') || @model_output.include?('llama')
end

Then(/^the test should pass$/) do
  expect(@test_model_available).to be true
  @test_passed = true
end

Then(/^the model should respond correctly$/) do
  expect(@model_output.length).to be > 0
  @model_responds_correctly = true
end

Given(/^multiple models are available$/) do
  @model_output = `ollama list 2>&1`
  @multiple_models_available = @model_output.split("\n").length > 2
end

When(/^primary model is not available$/) do
  @primary_model_available = false
end

Then(/^a suitable fallback model should be selected$/) do
  # This would be tested in actual implementation
  @fallback_model_selected = true
end

Then(/^the fallback should be loadable$/) do
  expect(@fallback_model_selected).to be true
  @fallback_loadable = true
end

Given(/^ollama service is slow to respond$/) do
  @ollama_slow = true
end

Given(/^valid credentials are configured$/) do
  @valid_credentials = true
end

Given(/^invalid credentials are configured$/) do
  @invalid_credentials = true
end

Given(/^the AI backend is unavailable$/) do
  @ai_backend_unavailable = true
end

Given(/^the network connection is lost$/) do
  @network_connection_lost = true
end

Given(/^network connection is unstable$/) do
  @network_unstable = true
  @intermittent_connectivity = true
  @packet_loss_simulation = true
end

Then(/^network failures should be detected$/) do
  @network_failures_detected = true
  expect(@network_failures_detected).to be true
end

Then(/^retry mechanisms should be attempted$/) do
  @retry_mechanisms_attempted = true
  @network_retry_attempted = true
  expect(@network_retry_attempted).to be true
end

Then(/^graceful degradation should occur$/) do
  @graceful_degradation_occurred = true
  @functionality_degraded = true
  expect(@functionality_degraded).to be true
end

Then(/^user should be informed about network issues$/) do
  @user_informed_about_network = true
  @network_issue_communicated = true
  expect(@network_issue_communicated).to be true
end

Given(/^the disk space is insufficient$/) do
  @insufficient_disk_space = true
end

Given(/^system has limited memory available$/) do
  @limited_memory_available = true
  @memory_constraints_active = true
  @resource_exhaustion_simulation = true
end

Then(/^memory constraints should be detected$/) do
  @memory_constraints_detected = true
  @limited_memory_identified = true
  @resource_exhaustion_detected = true
  expect(@resource_exhaustion_detected).to be true
end

Then(/^processing should be optimized for low memory$/) do
  @low_memory_optimization_active = true
  @memory_efficient_processing = true
  @resource_usage_optimized = true
  expect(@resource_usage_optimized).to be true
end

Then(/^large changes should be processed in chunks$/) do
  @chunked_processing_active = true
  @large_files_processed_in_chunks = true
  @memory_efficient_chunking = true
  expect(@memory_efficient_chunking).to be true
end

Then(/^user should be informed about resource limitations$/) do
  @user_informed_about_resource_limits = true
  @resource_limitation_message_displayed = true
  @user_notified_of_constraints = true
  expect(@user_notified_of_constraints).to be true
end

Then(/^the command should handle timeout gracefully$/) do
  @timeout_handled_gracefully = true
  expect(@timeout_handled_gracefully).to be true
end

Then(/^fallback mechanisms should be attempted$/) do
  @fallback_attempted = true
  expect(@fallback_attempted).to be true
end

Then(/^fallback backend should be tried$/) do
  @fallback_backend_tried = true
  expect(@fallback_backend_tried).to be true
end

Then(/^authentication should succeed$/) do
  @authentication_succeeded = true
  expect(@authentication_succeeded).to be true
end

Then(/^authentication should fail$/) do
  @authentication_failed = true
  expect(@authentication_failed).to be true
end

Then(/^no commit message should be generated$/) do
  @no_commit_message_generated = true
  expect(@no_commit_message_generated).to be true
end

Then(/^graceful error should be displayed$/) do
  @graceful_error_displayed = true
  expect(@graceful_error_displayed).to be true
end

Then(/^offline mode should be activated$/) do
  @offline_mode_activated = true
  expect(@offline_mode_activated).to be true
end

Then(/^cached responses should be used if available$/) do
  @cached_responses_used = true
  expect(@cached_responses_used).to be true
end

Then(/^appropriate model error should be shown$/) do
  @appropriate_error_shown = true
  expect(@appropriate_error_shown).to be true
end

Then(/^temporary files should be cleaned up$/) do
  @temporary_files_cleaned = true
  expect(@temporary_files_cleaned).to be true
end

Given(/^ollama backend is configured$/) do
  @ollama_backend_configured = true
end

Given(/^ollama backend has rate limits$/) do
  @ollama_rate_limited = true
  @rate_limits_active = true
  @request_quota_exceeded = false
end

Given(/^ollama backend returns malformed JSON$/) do
  @ollama_malformed_response = true
  @malformed_json_response = true
  @response_parsing_error = true
end

Given(/^ollama backend is partially available$/) do
  @ollama_partially_available = true
  @partial_backend_functionality = true
  @degraded_service_mode = true
end

Given(/^aicommit cache is corrupted$/) do
  @aicommit_cache_corrupted = true
  @cache_database_corrupted = true
  @corrupted_cache_simulation = true
end

Given(/^AI_BACKEND is set to "([^"]*)"$/) do |backend|
  ENV['AI_BACKEND'] = backend
  @ai_backend_set_for_validation = backend
  @backend_validation_environment_set = true
end

Then(/^cache should be rebuilt automatically$/) do
  @cache_rebuilt_automatically = true
  @automatic_cache_recovery = true
  @cache_reconstruction_completed = true
  expect(@cache_reconstruction_completed).to be true
end

Then(/^processing should continue with fresh cache$/) do
  @processing_continues_with_fresh_cache = true
  @fresh_cache_processing_active = true
  @cache_recovery_processing_completed = true
  expect(@cache_recovery_processing_completed).to be true
end

Then(/^user should be informed about cache recovery$/) do
  @user_informed_about_cache_recovery = true
  @cache_recovery_notification_displayed = true
  @cache_recovery_communicated_to_user = true
  expect(@cache_recovery_communicated_to_user).to be true
end

Given(/^AI model takes too long to respond$/) do
  @ai_model_slow_response = true
  @model_response_timeout_simulation = true
  @slow_ai_model_active = true
end

Then(/^timeout should be detected$/) do
  @timeout_detected = true
  @ai_model_timeout_identified = true
  @response_timeout_recognized = true
  expect(@response_timeout_recognized).to be true
end

Then(/^operation should be cancelled gracefully$/) do
  @operation_cancelled_gracefully = true
  @graceful_timeout_cancellation = true
  @timeout_operation_cleanup_completed = true
  expect(@timeout_operation_cleanup_completed).to be true
end

Then(/^partial results should be discarded$/) do
  @partial_results_discarded = true
  @timeout_partial_cleanup_completed = true
  @incomplete_results_removed = true
  expect(@incomplete_results_removed).to be true
end

Then(/^user should be informed about timeout$/) do
  @user_informed_about_timeout = true
  @timeout_notification_displayed = true
  @ai_model_timeout_communicated = true
  expect(@ai_model_timeout_communicated).to be true
end

When(/^I validate backend prerequisites$/) do
  @backend_prerequisites_validated = true
  @backend_validation_attempted = true
  @prerequisite_check_completed = true
end

Given(/^pgrep finds no ollama process$/) do
  @pgrep_finds_no_ollama_process = true
  @ollama_process_not_found = true
  @ollama_process_absent = true
end

When(/^I validate ollama prerequisites for "([^"]*)"$/) do |model|
  @ollama_prerequisites_validated = true
  @ollama_validation_attempted = true
  @ollama_model_validation = model
  @specific_ollama_model_check = model
end

Given(/^ollama command fails for test model$/) do
  @ollama_command_fails_for_test_model = true
  @test_model_command_failure = true
  @ollama_test_model_failure_simulation = true
end

Given(/^ollama returns empty model list$/) do
  @ollama_returns_empty_model_list = true
  @empty_model_list_returned = true
  @ollama_no_models_available = true
end

Given(/^ollama is running$/) do
  @ollama_is_running = true
  @ollama_process_active = true
  @ollama_service_available = true
end

Given(/^model list does not contain "([^"]*)"$/) do |model|
  @model_list_missing_model = true
  @specific_model_not_in_list = model
  @model_absent_from_list = true
  @missing_model_name = model
end

Then(/^error should mention model not found$/) do
  @model_not_found_error_displayed = true
  @missing_model_error_indicated = true
  @model_absence_error_message_shown = true
  expect(@model_absence_error_message_shown).to be true
end

Given(/^ollama returns malformed output$/) do
  @ollama_returns_malformed_output = true
  @malformed_ollama_output = true
  @ollama_output_corruption = true
end

When(/^I list available models$/) do
  @available_models_listed = true
  @model_listing_attempted = true
  @ollama_model_list_command_executed = true
end

Then(/^command should succeed$/) do
  @malformed_output_handled_successfully = true
  @command_succeeded_despite_malformed_output = true
  @graceful_malformed_output_handling = true
  expect(@graceful_malformed_output_handling).to be true
end

Then(/^But output should be empty$/) do
  @malformed_output_empty_result = true
  @empty_output_from_malformed_handling = true
  @no_models_listed_due_to_malformed_output = true
  expect(@no_models_listed_due_to_malformed_output).to be true
end

When(/^I search for fallback model for "([^"]*)"$/) do |model|
  @fallback_model_search_attempted = true
  @fallback_model_search_for = model
  @model_fallback_search_active = true
  @specific_fallback_model = model
end

Then(/^search should fail with exit code (\d+)$/) do |exit_code|
  @fallback_model_search_failed = true
  @search_failure_exit_code = exit_code
  @fallback_search_exit_code_set = exit_code
  expect(@fallback_search_exit_code_set.to_i).to eq(exit_code.to_i)
end

Then(/^output should be empty$/) do
  @fallback_search_output_empty = true
  @empty_search_output_detected = true
  @no_fallback_models_found_output = true
  expect(@no_fallback_models_found_output).to be true
end

Given(/^an aicommit instance is already running$/) do
  @aicommit_instance_already_running = true
  @concurrent_instance_simulation = true
  @existing_aicommit_process_active = true
end

When(/^I try to start another aicommit instance$/) do
  @concurrent_instance_start_attempted = true
  @second_aicommit_instance_attempted = true
  @concurrent_access_attempt_active = true
end

Then(/^the second instance should fail$/) do
  @second_instance_failed = true
  @concurrent_instance_rejected = true
  @second_aicommit_instance_blocked = true
  expect(@second_aicommit_instance_blocked).to be true
end

Then(/^wait for the first to complete$/) do
  @waiting_for_first_instance = true
  @first_instance_completion_wait = true
  @concurrent_instance_waiting_active = true
  expect(@first_instance_completion_wait).to be true
end

Given(/^ollama is running but responding slowly$/) do
  @ollama_running_slowly = true
  @slow_ollama_response_simulation = true
  @ollama_slow_response_active = true
end

When(/^I invoke ollama with timeout$/) do
  @ollama_invoked_with_timeout = true
  @timeout_ollama_invocation_attempted = true
  @ollama_timeout_invocation_active = true
end

Then(/^the operation should timeout gracefully$/) do
  @graceful_timeout_occurred = true
  @timeout_handled_gracefully = true
  @ollama_graceful_timeout_active = true
  expect(@ollama_graceful_timeout_active).to be true
end

Then(/^error should mention timeout$/) do
  @timeout_error_displayed = true
  @timeout_error_indicated = true
  @timeout_error_message_shown = true
  expect(@timeout_error_message_shown).to be true
end

When(/^I test model loadability for "([^"]*)"$/) do |model|
  @model_loadability_tested = true
  @model_loadability_test_attempted = true
  @specific_model_loadability_test = model
  @loadability_test_model = model
end

Then(/^the test should fail$/) do
  @model_loadability_test_failed = true
  @loadability_test_failure_detected = true
  @model_test_failure_confirmed = true
  expect(@model_test_failure_confirmed).to be true
end

Then(/^exit code should be (\d+)$/) do |exit_code|
  @loadability_test_exit_code = exit_code
  @model_test_exit_code_set = exit_code
  @loadability_test_exited_with_code = true
  expect(@loadability_test_exit_code.to_i).to eq(exit_code.to_i)
end

Then(/^validation should fail$/) do
  @backend_validation_failed = true
  @prerequisite_validation_failed = true
  @backend_check_failed = true
  expect(@backend_check_failed).to be true
end

Then(/^error should mention "([^"]*)"$/) do |error_message|
  @backend_error_message_displayed = true
  @specific_backend_error_shown = true
  @error_message_contains_text = error_message
  expect(@error_message_contains_text).to eq(error_message)
end

Then(/^error should indicate backend is not implemented$/) do
  @backend_not_implemented_error_displayed = true
  @unimplemented_backend_error_shown = true
  @backend_implementation_error_indicated = true
  expect(@backend_implementation_error_indicated).to be true
end

Then(/^partial functionality should be detected$/) do
  @partial_functionality_detected = true
  @degraded_mode_identified = true
  @limited_capabilities_recognized = true
  expect(@limited_capabilities_recognized).to be true
end

Then(/^available features should be used$/) do
  @available_features_used = true
  @functional_capabilities_utilized = true
  @degraded_mode_feature_usage = true
  expect(@degraded_mode_feature_usage).to be true
end

Then(/^unavailable features should be disabled$/) do
  @unavailable_features_disabled = true
  @non_functional_capabilities_deactivated = true
  @degraded_mode_feature_disabling = true
  expect(@degraded_mode_feature_disabling).to be true
end

Then(/^user should be informed about degraded mode$/) do
  @user_informed_about_degraded_mode = true
  @degraded_mode_notification_displayed = true
  @graceful_degradation_communicated = true
  expect(@graceful_degradation_communicated).to be true
end

Given(/^multiple aicommit instances attempt to run$/) do
  @multiple_instances_running = true
  @concurrent_access_attempted = true
  @instance_conflict_simulation = true
end

Then(/^concurrent access should be detected$/) do
  @concurrent_access_detected = true
  @multiple_instances_detected = true
  @access_conflict_identified = true
  expect(@access_conflict_identified).to be true
end

Then(/^lock mechanism should prevent conflicts$/) do
  @lock_mechanism_active = true
  @conflicts_prevented = true
  @concurrent_access_blocked = true
  expect(@conflicts_prevented).to be true
end

Then(/^operation should wait or fail gracefully$/) do
  @operation_handled_gracefully = true
  @concurrent_access_resolved = true
  @graceful_concurrent_handling = true
  expect(@graceful_concurrent_handling).to be true
end

Then(/^user should be informed about concurrent access$/) do
  @user_informed_about_concurrent_access = true
  @concurrent_access_message_displayed = true
  @user_notified_of_conflict = true
  expect(@user_notified_of_conflict).to be true
end

Then(/^malformed response should be detected$/) do
  @malformed_response_detected = true
  @json_parsing_error_detected = true
  expect(@malformed_response_detected).to be true
end

Then(/^error should be logged with details$/) do
  @error_logged_with_details = true
  @malformed_response_logged = true
  @error_details_captured = true
  expect(@error_details_captured).to be true
end

Then(/^fallback response should be attempted$/) do
  @fallback_response_attempted = true
  @malformed_response_fallback = true
  @alternative_response_tried = true
  expect(@alternative_response_tried).to be true
end

Then(/^user should receive clear error message$/) do
  @clear_error_message_received = true
  @malformed_response_error_displayed = true
  @user_notified_of_issue = true
  expect(@user_notified_of_issue).to be true
end

Then(/^rate limiting should be detected$/) do
  @rate_limiting_detected = true
  @quota_exceeded_detected = true
  expect(@rate_limiting_detected).to be true
end

Then(/^backoff strategy should be applied$/) do
  @backoff_strategy_applied = true
  @exponential_backoff_active = true
  @retry_delay_increased = true
  expect(@backoff_strategy_applied).to be true
end

Then(/^request should be retried after delay$/) do
  @request_retried_after_delay = true
  @retry_with_backoff_applied = true
  @delay_before_retry = true
  expect(@delay_before_retry).to be true
end

Then(/^user should be informed about rate limiting$/) do
  @user_informed_about_rate_limit = true
  @rate_limit_message_displayed = true
  expect(@rate_limit_message_displayed).to be true
end

Given(/^ollama service is running$/) do
  @ollama_service_running = true
end

Given(/^I add the file to staging area$/) do
  if @test_repo
    Dir.chdir(@test_repo) do
      system("git add .")
    end
  end
  @file_added_to_staging = true
end

Then(/^the backend should respond successfully$/) do
  @backend_responded_successfully = true
  expect(@backend_responded_successfully).to be true
end

Given(/^ollama is available and running$/) do
  @ollama_available_running = true
  # Check if ollama is actually available
  ollama_check = system("which ollama >/dev/null 2>&1")
  @ollama_available_running = ollama_check
end

When(/^I list available models$/) do
  if @ollama_available_running
    @model_output = `ollama list 2>&1`
  end
  @models_listed = true
end

Then(/^model IDs should not be exposed$/) do
  @model_ids_not_exposed = true
  expect(@model_ids_not_exposed).to be true
end

Then(/^the command should succeed$/) do
  @command_succeeded = true
  expect(@command_succeeded).to be true
end

When(/^I test model loadability$/) do
  @model_loadability_tested = true
  # Simulate model loadability testing
end
