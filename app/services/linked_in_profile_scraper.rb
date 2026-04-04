class LinkedInProfileScraper
  def initialize(url)
    @url = normalize_url(url)
  end

  def scrape
    return nil if @url.blank?

    html = fetch_html
    return nil unless html

    {
      name: extract_name(html),
      headline: extract_headline(html),
      location: extract_location(html),
      summary: extract_summary(html),
      linkedin_url: @url
    }.compact_blank
  rescue => e
    Rails.logger.error("[LinkedInProfileScraper] Failed: #{e.message}")
    nil
  end

  private

  def normalize_url(url)
    url = url.to_s.strip
    return nil if url.blank?
    url = "https://#{url}" unless url.start_with?("http")
    url.split("?").first # Remove query params
  end

  def fetch_html
    uri = URI(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 15
    http.open_timeout = 10

    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    req["Accept"] = "text/html"
    req["Accept-Language"] = "en-US,en;q=0.5"

    resp = http.request(req)
    resp.code.to_i == 200 ? resp.body : nil
  end

  def extract_name(html)
    html[/<h1[^>]*>([^<]+)<\/h1>/m, 1]&.strip ||
      html[/class="[^"]*top-card-layout__title[^"]*"[^>]*>([^<]+)/m, 1]&.strip
  end

  def extract_headline(html)
    html[/class="[^"]*text-body-medium[^"]*"[^>]*>([^<]+)/m, 1]&.strip ||
      html[/class="[^"]*top-card-layout__headline[^"]*"[^>]*>([^<]+)/m, 1]&.strip
  end

  def extract_location(html)
    html[/class="[^"]*top-card-layout__first-subline[^"]*"[^>]*>\s*([^<]+)/m, 1]&.strip ||
      html[/class="[^"]*top-card__subline-item[^"]*"[^>]*>([^<]+)/m, 1]&.strip
  end

  def extract_summary(html)
    about = html[/class="[^"]*summary[^"]*"[^>]*>(.*?)<\/section>/m, 1] ||
            html[/class="[^"]*about[^"]*"[^>]*>(.*?)<\/section>/m, 1]
    return nil unless about
    about.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip.truncate(1000)
  end
end
