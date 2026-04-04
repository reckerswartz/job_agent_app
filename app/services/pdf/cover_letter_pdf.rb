module Pdf
  class CoverLetterPdf
    def initialize(cover_letter)
      @cover_letter = cover_letter
      @listing = cover_letter.job_listing
      @profile = cover_letter.profile
    end

    def render
      Prawn::Document.new(page_size: "LETTER", margin: [ 72, 72, 72, 72 ]) do |pdf|
        pdf.font_size 11

        # Header: candidate info
        pdf.text profile.display_name, size: 16, style: :bold
        pdf.text profile.headline.to_s, size: 10, color: "666666"
        contact_line = [ profile.contact_field("email"), profile.contact_field("phone") ].reject(&:blank?).join(" | ")
        pdf.text contact_line, size: 9, color: "888888" if contact_line.present?
        pdf.move_down 20

        # Date
        pdf.text Date.current.strftime("%B %d, %Y"), size: 10
        pdf.move_down 10

        # Addressee
        pdf.text listing.company.to_s, style: :bold
        pdf.text "Re: #{listing.title}", size: 10, color: "444444"
        pdf.move_down 16

        # Body
        cover_letter.content.split("\n\n").each do |paragraph|
          pdf.text paragraph.strip, leading: 4, align: :justify
          pdf.move_down 10
        end

        # Signature
        pdf.move_down 10
        pdf.text "Sincerely,"
        pdf.move_down 6
        pdf.text profile.display_name, style: :bold
      end.render
    end

    private

    attr_reader :cover_letter, :listing, :profile
  end
end
