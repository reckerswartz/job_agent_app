class InterventionCreator
  def self.create_for(interventionable, type:, context: {}, user:)
    intervention = Intervention.create!(
      interventionable: interventionable,
      intervention_type: type,
      context: context,
      user: user
    )

    if user.notify?("email_interventions")
      NotificationMailer.intervention_needed(user, intervention).deliver_later
    end

    intervention
  end
end
