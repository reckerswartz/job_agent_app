module JobApplier
  class FormFiller
    def initialize(profile)
      @mapper = FormMapper.new(profile)
    end

    def fill_instructions(form_fields)
      @mapper.map_fields(form_fields)
    end

    def form_data_snapshot
      @mapper.to_form_data
    end

    private

    attr_reader :mapper
  end
end
