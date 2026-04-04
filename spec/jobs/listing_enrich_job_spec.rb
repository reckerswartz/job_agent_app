require "rails_helper"

RSpec.describe ListingEnrichJob, type: :job do
  let(:user) { create(:user) }
  let(:job_source) { create(:job_source, user: user) }
  let(:listing) { create(:job_listing, job_source: job_source) }

  describe "#perform" do
    it "calls ListingEnricher with the listing" do
      enricher = instance_double("ListingEnricher")
      allow(ListingEnricher).to receive(:new).with(listing).and_return(enricher)
      allow(enricher).to receive(:enrich)

      described_class.new.perform(listing.id)
      expect(enricher).to have_received(:enrich)
    end
  end
end
