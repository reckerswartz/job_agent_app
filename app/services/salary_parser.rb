class SalaryParser
  # Parses salary text like "$120K - $160K", "₹15L - ₹25L", "$50/hr", "120000-160000"
  # Returns: { min: Integer, max: Integer, currency: String, period: String }

  CURRENCY_MAP = {
    "$" => "USD", "₹" => "INR", "£" => "GBP", "€" => "EUR",
    "usd" => "USD", "inr" => "INR", "gbp" => "GBP", "eur" => "EUR"
  }.freeze

  def parse(text)
    return nil if text.blank?

    t = text.to_s.strip.downcase
    currency = detect_currency(text)
    period = detect_period(t)

    numbers = extract_numbers(t)
    return nil if numbers.empty?

    min_val = normalize_value(numbers.first, t)
    max_val = numbers.size > 1 ? normalize_value(numbers.last, t) : min_val

    # Swap if reversed
    min_val, max_val = max_val, min_val if min_val > max_val

    # Annualize hourly rates
    if period == "hour"
      min_val = (min_val * 2080).round
      max_val = (max_val * 2080).round
      period = "year"
    elsif period == "month"
      min_val = (min_val * 12).round
      max_val = (max_val * 12).round
      period = "year"
    end

    { min: min_val.to_i, max: max_val.to_i, currency: currency, period: period }
  end

  private

  def detect_currency(text)
    CURRENCY_MAP.each do |symbol, code|
      return code if text.include?(symbol)
    end
    "USD"
  end

  def detect_period(text)
    return "hour" if text.match?(/\/\s*h|per\s*hour|hourly|\/hr/)
    return "month" if text.match?(/\/\s*mo|per\s*month|monthly|\/month/)
    "year"
  end

  def extract_numbers(text)
    # Remove currency symbols and commas, then find numeric patterns
    cleaned = text.gsub(/[$₹£€,]/, "")
    cleaned.scan(/[\d]+\.?\d*/).map(&:to_f).select { |n| n > 0 }
  end

  def normalize_value(num, text)
    # Handle K suffix: 120K → 120000
    if text.match?(/#{num.to_i}\s*k/i) || (num < 1000 && num > 10 && !text.match?(/\/\s*h|hourly/))
      return (num * 1000).round
    end

    # Handle L/Lakh suffix (Indian): 15L → 1500000
    if text.match?(/#{num.to_i}\s*l(?:akh|ac|pa)?/i)
      return (num * 100_000).round
    end

    # Handle Cr/Crore suffix: 1.5Cr → 15000000
    if text.match?(/#{num.to_i}\s*cr/i)
      return (num * 10_000_000).round
    end

    num.round
  end
end
