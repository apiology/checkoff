# frozen_string_literal: true

desc 'Make release'
task release: %i[trigger_next_builds]
