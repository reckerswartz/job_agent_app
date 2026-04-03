module Api
  module V1
    class ProfilesController < Api::BaseController
      def show
        profile = current_user.profiles.first
        return render json: { error: "No profile found." }, status: :not_found unless profile

        render_json({
          id: profile.id, title: profile.title, headline: profile.headline,
          summary: profile.summary, status: profile.status,
          contact_details: profile.contact_details,
          processing_status: profile.processing_status,
          completeness: profile.completeness_percentage,
          sections: profile.profile_sections.order(:position).map { |s|
            { type: s.section_type, title: s.title, entries_count: s.profile_entries.count }
          }
        })
      end
    end
  end
end
