require 'test_helper'

describe Til do
  it 'has a run method' do
    github_client_mock = Minitest::Mock.new
    github_client_mock.expect :contents, [], ['pjambet/til', { path: '' }]

    Process.stubs(:spawn).returns(12)

    Til::Core.new(
      process: Process,
      stderr: StringIO.new,
      env: { 'GH_TOKEN' => 'abc', 'VISUAL' => 'vim' },
      github_client: github_client_mock,
    ).run
  end

  it 'exits if GH_TOKEN is nil or empty' do
    error = assert_raises RuntimeError do
      Til::Core.new(env: {}).run
    end
    assert_match 'The GH_TOKEN (with the public_repo or repo scope) environment variable is required', error.message
  end

  it 'exits if both VISUAL and EDITOR are nil or empty' do
    error = assert_raises RuntimeError do
      Til::Core.new(env: { 'GH_TOKEN' => 'abc' }).run
    end
    assert_match 'The VISUAL or EDITOR environment variables are required', error.message

    error = assert_raises RuntimeError do
      Til::Core.new(env: { 'GH_TOKEN' => 'abc', 'VISUAL' => '' }).run
    end
    assert_match 'The VISUAL or EDITOR environment variables are required', error.message
  end

  it 'exits if fzf is not available' do
    error = assert_raises RuntimeError do
      kernel_mock = Minitest::Mock.new
      kernel_mock.expect :system, false, ['which fzf', { out: '/dev/null', err: '/dev/null' }]
      Til::Core.new(kernel: kernel_mock, env: { 'GH_TOKEN' => 'abc' }).run
    end
    assert_match "fzf is required, you can install it on macOS with 'brew install fzf'", error.message
  end
end
