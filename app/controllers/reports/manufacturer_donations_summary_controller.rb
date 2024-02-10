class Reports::ManufacturerDonationsSummaryController < ApplicationController
  def index
    setup_date_range_picker

    @recent_donations_from_manufacturers = current_organization.donations.during(helpers.selected_range).by_source(:manufacturer)
    @top_manufacturers = current_organization.manufacturers.by_donation_count
    @donations = current_organization.donations.during(helpers.selected_range)
    @recent_donations = @donations.recent
  end
end