class ConvenienceStore
  def self.[](key)
    (@@cache ||= {})[key]
  end

  def self.[]=(key, value)
    (@@cache ||= {})[key] = value
  end
end
