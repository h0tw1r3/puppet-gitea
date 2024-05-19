desc 'Run all tests EXCEPT acceptance'
task test: ['test:check', 'test:syntax', 'test:lint', 'test:doc', 'test:unit']

namespace :test do
  desc 'Run static pre-release checks'
  task check: [:check]

  desc 'Run syntax checks'
  task syntax: [:syntax]

  desc 'Run linters'
  task lint: [:lint, :metadata_lint, :rubocop]

  desc 'Run documentation tests'
  task doc: ['strings:validate:reference']

  desc 'Run all unit tests in parallel'
  task unit: [:parallel_spec]

  desc 'Run acceptance tests'
  task acceptance: [:acceptance]
end
