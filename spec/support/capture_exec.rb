# Courtesy of:
# https://raw.github.com/cupakromer/tao-of-tdd/master/adder/spec/support/capture_exec.rb
require 'open3'

def exec_io(*cmd)
  cmd = cmd.flatten
  out_err, _exit_code = Open3.capture2e(*cmd)

  out_err
end
