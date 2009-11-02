class EgyptException < Exception
  def initialize(stdout, stderr)
    delimiter_line = "-------------------------------------------------\n"
    report = []
    report.push "Standard output:\n"
    report.push delimiter_line
    report.push stdout
    report.push delimiter_line
    if !stderr.empty?
      report.push "\n"
      report.push "Standard error:\n"
      report.push delimiter_line
      report.push stderr
      report.push delimiter_line
    end
    report.push "\n"
    super(report.join)
  end
end
