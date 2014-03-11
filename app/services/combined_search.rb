class CombinedSearch
  attr_accessor :query, :error

  def initialize(full_query)
    @full_query = full_query
    @error = false
  end

  def search
    {
      recommendations: Recommendation.recommend(@full_query[:q]),
      sitesearch: siteseeker_search
    }
  end

  def completion
    {
      recommendations: Recommendation.recommend(@full_query[:q]),
      sitesearch: siteseeker_completion
    }
  end

  private
    def siteseeker_search
      begin
        raw_results = Rails.cache.fetch(["search-raw-results", @full_query], expires_in: 16.hours) do
          client = SiteseekerNormalizer::Client.new(APP_CONFIG['siteseeker']['account'], APP_CONFIG['siteseeker']['index'], encoding: "UTF-8")
          raw_results = client.fetch(@full_query)
        end
        SiteseekerNormalizer::Parse.new(raw_results, encoding: "UTF-8")
      rescue Exception => e
        Rails.logger.error "Sitesearch: #{e}"
        @error = e
      end
    end

    def siteseeker_completion
      begin
        Rails.cache.fetch(["search-autocomplete", @full_query], expires_in: 16.hours) do
          open("#{APP_CONFIG['autocomplete_url']}?q=#{CGI.escape(@full_query[:q])}&ilang=sv", read_timeout: 1).first
        end
      rescue Exception => e
        Rails.logger.error "Siteseeker completion: #{e}"
        {} # Silent error
      end
    end
end
