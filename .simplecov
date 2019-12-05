require "simplecov-rcov-text"
require "colorize"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::RcovTextFormatter,
  SimpleCov::Formatter::HTMLFormatter
])
SimpleCov.start do
  add_filter "/spec/"

  # Fail the build when coverage is weak:
  at_exit do
    SimpleCov.result.format!
    threshold, actual = 100.0, SimpleCov.result.covered_percent
    if actual < threshold then # FAIL
      msg = "\nLow coverage: "
      msg << "#{actual}%".colorize(:red)
      msg << " is " << "under".colorize(:red) << " the threshold: "
      msg << "#{threshold}%.".colorize(:green)
      msg << "\n"
      $stderr.puts msg
      exit 1
    else # PASS
      # Precision: three decimal places:
      actual_trunc = (actual * 1000).floor / 1000.0
      msg = "\nCoverage: "
      msg << "#{actual}%".colorize(:green)
      if actual_trunc > threshold
        msg << " is " << "over".colorize(:green) << " the threshold: "
        msg << "#{threshold}%. ".colorize(color: :yellow, mode: :bold)
        msg << "Please update the threshold to: "
        msg << "#{actual_trunc}% ".colorize(color: :green, mode: :bold)
        msg << "in ./.simplecov."
      else
        msg << " is " << "at".colorize(:green) << " the threshold: "
        msg << "#{threshold}%.".colorize(:green)
      end
      msg << "\n"
      $stdout.puts msg
    end
  end
end
