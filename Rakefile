require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-system/rake_task'

task :default do
  sh %{rake -T}
end

desc "Run rspec-puppet and puppet-lint tasks"
task :ci => [
  :spec,
  :lint,
]

# Disable puppet-lint checks
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_class_inherits_from_params_class")
PuppetLint.configuration.send('disable_class_parameter_defaults')
