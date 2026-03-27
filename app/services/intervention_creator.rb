class InterventionCreator
  def self.create_for(interventionable, type:, context: {}, user:)
    Intervention.create!(
      interventionable: interventionable,
      intervention_type: type,
      context: context,
      user: user
    )
  end
end
