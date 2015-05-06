# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'webmock/rspec'
require 'rack'

WebMock.disable_net_connect!(allow_localhost: false)
DIR = File.expand_path(File.dirname(__FILE__))

class RestartTimeoutRack
  def initialize(state_success_count = 10)
    @health_call_count = 0
    @state_call_count = 0

    @state_success_count = state_success_count
  end

  def call(env)
    case env['PATH_INFO']
    when '/_cluster/health'
      case @health_call_count
      when 1..4
        ret = File.read(DIR + '/fixtures/health_initializing.json')
      else
        ret = File.read(DIR + '/fixtures/health.json')
      end
      @health_call_count += 1
    when '/_cluster/settings'
      if env['rack.input'].read[/none/].nil?
        ret = '{"transient":{"cluster":{"routing":{"allocation":{"enable":"all"}}}}}'
      else
        ret = '{"transient":{"cluster":{"routing":{"allocation":{"enable":"none"}}}}}'
      end
    when '/_cluster/state'
      if @state_call_count < @state_success_count
        ret = File.read(DIR + '/fixtures/state.json')
      else
        ret = File.read(DIR + '/fixtures/state-node-initializing.json')
      end
      @state_call_count += 1
    end
    [200, { 'Content-Type' => 'application/json' }, [ret]]
  end
end

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
  config.before(:each) do
    stub_request(:get, /localhost:9200\/base\/client/).
      to_return(status: 200, body: 'requested: /base/client', headers: {})

    stub_request(:get, /localhost:9200\/_cluster\/health/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/health.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost-yellow:9200\/_cluster\/health/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/health_yellow.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost-red:9200\/_cluster\/health/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/health_red.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost-realocating:9200\/_cluster\/health/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/health_realocating.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost-initializing:9200\/_cluster\/health/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/health_initializing.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost-unassigned:9200\/_cluster\/health/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/health_unassigned.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost:9200\/_cluster\/state/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/state.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:get, /localhost:9200\/_nodes/).
      to_return(status: 200,
                body: File.read(DIR + '/fixtures/nodes_.json'),
                headers: {'Content-Type' => 'application/json'})

    stub_request(:put, /localhost-route-disabled:9200\/_cluster\/settings/).
      to_return(status: 200,
                body: '{"transient":{"cluster":{"routing":{"allocation":{"enable":"none"}}}}}',
                headers: {'Content-Type' => 'application/json'})

    stub_request(:put, /localhost-route-enabled:9200\/_cluster\/settings/).
      to_return(status: 200,
                body: '{"transient":{"cluster":{"routing":{"allocation":{"enable":"all"}}}}}',
                headers: {'Content-Type' => 'application/json'})

    stub_request(:put, /localhost:9200\/_cluster\/settings/).
      with(:body => '{"transient":{"cluster.routing.allocation.enable":"none"}}').
      to_return(status: 200,
                body: '{"transient":{"cluster":{"routing":{"allocation":{"enable":"none"}}}}}',
                headers: {'Content-Type' => 'application/json'})

    stub_request(:put, /localhost:9200\/_cluster\/settings/).
      with(:body => '{"transient":{"cluster.routing.allocation.enable":"all"}}').
      to_return(status: 200,
                body: '{"transient":{"cluster":{"routing":{"allocation":{"enable":"all"}}}}}',
                headers: {'Content-Type' => 'application/json'})


    stub_request(:any, /localhost-restart-timeout:9200\//).
      to_rack(RestartTimeoutRack.new)
    stub_request(:any, /localhost-cmd-restart-timeout:9200\//).
      to_rack(RestartTimeoutRack.new)

    stub_request(:any, /localhost-restart-stabilization:9200\//).
      to_rack(RestartTimeoutRack.new)
    stub_request(:any, /localhost-cmd-restart-stabilization:9200\//).
      to_rack(RestartTimeoutRack.new)

    stub_request(:any, /localhost-restart-not-available:9200\//).
      to_rack(RestartTimeoutRack.new(1))
    stub_request(:any, /localhost-cmd-restart-not-available:9200\//).
      to_rack(RestartTimeoutRack.new(1))
  end
end

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end
