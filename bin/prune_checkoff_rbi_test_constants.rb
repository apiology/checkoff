#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/checkoff/prune_rbi_test_constants'

Checkoff::PruneRbiTestConstants.call(ARGV[0] || 'rbi/checkoff.rbi')
