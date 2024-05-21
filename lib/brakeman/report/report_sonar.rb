class Brakeman::Report::Sonar < Brakeman::Report::Base
  def generate_report
    report_object = {
      rules: generate_rules,
      issues: all_warnings.map { |warning| issue_json(warning) }
    }
    JSON.pretty_generate(report_object)
  end

  private

  def generate_rules
    all_warnings.uniq(&:warning_code)
                .map { |warning| rule_json(warning) }
  end

  def rule_json(warning)
    {
      id: warning.warning_code,
      name: warning.warning_type,
      description: warning.message,
      engineId: 'Brakeman',
      cleanCodeAttribute: 'FORMATTED', # This is a placeholder, adjust as necessary
      impacts: [
        {
          softwareQuality: 'SECURITY',
          severity: severity_level_for(warning.confidence)
        }
      ]
    }
  end

  def issue_json(warning)
    {
      ruleId: warning.warning_code,
      effortMinutes: effort_minutes_for(warning.confidence),
      primaryLocation: {
        message: warning.message,
        filePath: warning.file.relative,
        textRange: {
          startLine: warning.line || 1,
          endLine: warning.line || 1
        }
      }
    }
  end

  def severity_level_for(confidence)
    case confidence
    when 0
      'HIGH'
    when 1
      'MEDIUM'
    else
      'LOW'
    end
  end

  def effort_minutes_for(confidence)
    (4 - confidence) * 15
  end
end
