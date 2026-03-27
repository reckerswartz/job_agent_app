module ResumeParser
  class Base
    def initialize(profile)
      @profile = profile
    end

    def extract_text
      raise NotImplementedError, "#{self.class}#extract_text must be implemented"
    end

    private

    attr_reader :profile
  end
end
