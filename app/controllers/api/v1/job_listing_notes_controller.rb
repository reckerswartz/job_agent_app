module Api
  module V1
    class JobListingNotesController < Api::BaseController
      before_action :set_listing

      def index
        notes = @listing.job_listing_notes.where(user: current_user).recent
        render_json(notes.map { |n| serialize_note(n) })
      end

      def create
        note = @listing.job_listing_notes.build(content: params[:content])
        note.user = current_user

        if note.save
          render_json(serialize_note(note), status: :created)
        else
          render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        note = @listing.job_listing_notes.where(user: current_user).find(params[:id])
        note.destroy
        head :no_content
      end

      private

      def set_listing
        @listing = JobListing.for_user(current_user).find(params[:job_listing_id])
      end

      def serialize_note(n)
        { id: n.id, content: n.content, created_at: n.created_at }
      end
    end
  end
end
