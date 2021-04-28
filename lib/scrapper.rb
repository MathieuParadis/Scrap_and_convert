class Scrapper
  
  def initialize(region)
    @url_mairies_region = "https://www.annuaire-des-mairies.com/#{region}.html"
    @url_annuaire_mairies = "https://www.annuaire-des-mairies.com/"
  end

  def get_townhall_email(townhall_url)
      page = Nokogiri::HTML(URI.open(townhall_url).read)
      email_address = page.css('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').map(&:text).join
      city_name = page.css('/html/body/div/main/section[2]/div/table/tbody/tr[1]/td[1]').map(&:text).join.split[-1]

      #put city name and email adress in a hash
      hash_town_email = {city_name => email_address}
  end

  def get_townhall_urls
      urls_array = []

      page = Nokogiri::HTML(URI.open(@url_mairies_region).read)
      a_tag_list = page.css('table table p a.lientxt')

      for i in 0..a_tag_list.length-1
          url = @url_annuaire_mairies + a_tag_list[i]['href']
          urls_array.push(url)
      end

      return urls_array
  end

  # def collect_townhalls_names_and_emails
  #     array_townhalls_names_and_emails = []
  #     for i in 0..get_townhall_urls.length-1
  #       p get_townhall_email(get_townhall_urls[i])
  #         array_townhalls_names_and_emails.push(get_townhall_email(get_townhall_urls[i]))
  #     end
  #     return array_townhalls_names_and_emails
  # end

  def save_as_JSON
    for i in 0..get_townhall_urls.length-1
      json_email = (get_townhall_email(get_townhall_urls[i])).to_json
      File.open("db/emails.json", "a") { |file| file.puts json_email}
    end
  end

  def save_as_csv
    for i in 0..get_townhall_urls.length-1
      csv_email = (get_townhall_email(get_townhall_urls[i])).to_a.flatten.to_csv
      File.open("db/emails.csv", "a") { |file| file.puts csv_email}
    end
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1Msy2TQTC75A_nO6mrw_dgSqGKcW4eUYh04PRtYcd3gQ").worksheets[0]
    
    j = 1

    for i in 0..get_townhall_urls.length-1
      array_name_and_email = get_townhall_email(get_townhall_urls[i]).flatten
      ws[j, 1] = array_name_and_email[0]
      ws[j, 2] = array_name_and_email[1]

      ws.save
      j += 1
    end
  end

end