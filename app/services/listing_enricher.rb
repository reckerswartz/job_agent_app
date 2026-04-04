class ListingEnricher
  def initialize(listing)
    @listing = listing
  end

  def enrich
    return if listing.url.blank?
    return if listing.description.present?

    html = fetch_detail_page(listing.url)
    return unless html

    extract_description(html)
    extract_metadata(html)
    listing.save! if listing.changed?

    Rails.logger.info("[ListingEnricher] Enriched: #{listing.title}")
  rescue => e
    Rails.logger.warn("[ListingEnricher] Failed for #{listing.id}: #{e.message}")
  end

  private

  attr_reader :listing

  def fetch_detail_page(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 20
    http.open_timeout = 10

    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    req["Accept"] = "text/html"

    resp = http.request(req)
    resp.code.to_i == 200 ? resp.body : nil
  rescue => e
    Rails.logger.warn("[ListingEnricher] HTTP failed: #{e.message}")
    nil
  end

  def extract_description(html)
    platform = listing.job_source&.platform

    desc = case platform
    when "linkedin"
      html[/show-more-less-html__markup[^>]*>(.*?)<\/div>/m, 1] ||
        html[/description__text[^>]*>(.*?)<\/section>/m, 1]
    when "indeed"
      html[/id="jobDescriptionText"[^>]*>(.*?)<\/div>/m, 1] ||
        html[/class="[^"]*jobsearch-JobComponent-description[^"]*"[^>]*>(.*?)<\/div>/m, 1]
    else
      html[/<meta[^>]*name="description"[^>]*content="([^"]+)"/i, 1]
    end

    if desc.present?
      listing.description = desc.gsub(/<[^>]+>/, " ").gsub(/&[a-z]+;/i, " ").gsub(/\s+/, " ").strip.truncate(3000)
    end
  end

  def extract_metadata(html)
    listing.easy_apply = true if html.include?("Easy Apply") && !listing.easy_apply?
    listing.resume_upload_supported = listing.easy_apply

    loc = listing.location.to_s.downcase
    combined = "#{loc} #{html[0..5000]}".downcase
    if combined.include?("remote") && listing.remote_type.blank?
      listing.remote_type = "remote"
    elsif combined.include?("hybrid") && listing.remote_type.blank?
      listing.remote_type = "hybrid"
    end
  end
end
