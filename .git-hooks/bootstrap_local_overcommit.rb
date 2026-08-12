# typed: true
# frozen_string_literal: true

# Link machine-local Overcommit config across git worktrees and defer signature
# verification until `overcommit --sign` has run in this worktree (via fix.sh).
require 'yaml'
require 'fileutils'

# @param path [String]
# @return [Hash, nil]
def load_local_overcommit_config(path)
  data = YAML.load_file(path)
  data.is_a?(Hash) ? data : nil
rescue StandardError
  nil
end

# @param repo_root [String]
# @return [String, nil]
def sibling_worktree_local_overcommit(repo_root)
  String(`git worktree list --porcelain 2>/dev/null`).each_line do |line|
    next unless line.start_with?('worktree ')

    worktree = line.delete_prefix('worktree ').strip
    next if worktree == repo_root

    candidate = File.join(worktree, '.local-overcommit.yml')
    return candidate if File.exist?(candidate)
  end
  nil
end

repo_root = String(`git rev-parse --show-toplevel 2>/dev/null`).strip
exit if repo_root.empty?

local_file = File.join(repo_root, '.local-overcommit.yml')

unless File.exist?(local_file)
  source = sibling_worktree_local_overcommit(repo_root)
  # @sg-ignore tool-limitation:pr-1281-follow-on
  #   https://github.com/castwide/solargraph/pull/1281 merged (branch 2026-08-04 @
  #   4dae548) but does not clear this call: still "Wrong argument type for
  #   FileUtils.ln_sf: src expected FileUtils::path, Array, received String".
  #   Confirmed via strip-and-observe against the post-merge revision with a cleared
  #   pin cache. This src param is FileUtils::pathlist (path | Array[path]), not the
  #   dest param's plain FileUtils::path that #1281's repro targeted -- may be a
  #   distinct alias-expansion gap, or a partial fix. Not yet re-filed.
  FileUtils.ln_sf(source, local_file) if source
end

return unless File.exist?(local_file)

raw_config = load_local_overcommit_config(local_file)
return unless raw_config&.[]('verify_signatures') == false

signed = String(`git config --local --get overcommit.configuration.verifysignatures 2>/dev/null`).strip
ENV['OVERCOMMIT_NO_VERIFY'] = '1' if signed != '0'
