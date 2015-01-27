Feature: View Dashboard
	As a user
	I want to view my dashboard
	To get an overview of my data

	@todo
	Scenario: Not logged in
		Given that I am not logged in
		When I visit the admin dashboard page
		Then I should be on the login page

	@todo
	Scenario: Admin Logged in
		Given that I am logged in as an admin
		When I visit the dashboard page
		Then I should be on the admin dashboard page

	@todo
	Scenario: User Logged in
		Given that I am logged in
		When I visit the dashboard page
		Then I should be on the dashboard page