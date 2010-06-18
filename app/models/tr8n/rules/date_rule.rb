class Tr8n::DateRule < Tr8n::LanguageRule
  
  def self.description
    "token object may be a date, which"
  end
  
  def self.dependency
    "date" 
  end

  def self.suffixes
    Tr8n::Config.rules_engine[:date_rule][:token_suffixes]
  end

  def self.default_rules_for(language = Tr8n::Config.current_language)
    Tr8n::Config.default_date_rules(language.locale)
  end
  
  def self.operator_options
    [["is in the", "is_in"]]
  end

  def self.date_options
    [["past", "past"], ["present", "present"], ["future", "future"]]
  end

  def self.date_token_value(token)
    return nil unless token and token.respond_to?(Tr8n::Config.rules_engine[:date_rule][:object_method])
    token.send(Tr8n::Config.rules_engine[:date_rule][:object_method])
  end

  def date_token_value(token)
    self.class.date_token_value(token)
  end

  # FORM: [object, past, present, future]
  # {date | did, is doing, will do}
  def self.transform(*args)
    if args.size != 4
      raise Tr8n::Exception.new("Invalid transform arguments")
    end
    
    object = args[0]
    object_date = date_token_value(object)

    unless object_date
      raise Tr8n::Exception.new("Token #{object.class.name} does not respond to #{Tr8n::Config.rules_engine[:date_rule][:object_method]}")
    end

    current_date = Date.today
    
    if token_date < current_date
      return args[1]
    elsif token_date > current_date
      return args[3]
    end
    
    args[2]
  end  

  def evaluate(token)
    # for now - until we cleanup tokens
    return false unless token.is_a?(Date) or token.is_a?(Time)
    
    token_date = date_token_value(token)
    return false unless token_date
    
    current_date = Date.today
    
    case definition[:value]
      when "past" then
          return true if token_date < current_date
      when "present" then
          return true if token_date == current_date
      when "future" then
          return true if token_date > current_date
    end

    false    
  end

  # used by language rules setup page
  def token_description
    if self.class.date_options.collect{|o| o.last}.include?(definition[:value])
      return "token object may be a date, which is in the <strong>#{definition[:value]}</strong>"
    end
    
    "unknown rule"
  end

  # used to describe a context of a given translation
  def description
    if self.class.date_options.collect{|o| o.last}.include?(definition[:value])
      return "is in the #{definition[:value]}"
    end
    
    "unknown rule"
  end
end
