require 'spec_helper'

feature 'User registration', register: true do

  background do
    FakeWeb.allow_net_connect = true
    Capybara.reset_session!
  end

  scenario 'registers a new user', js: true do
    visit root_path
    page.should have_content("Register")
    click_link 'Register'
    wait_until(10) { page.has_css? '#password_confirmation' }
    fill_in 'email', :with => 'user123@example.com'
    fill_in 'password', :with => 'password'
    fill_in 'password_confirmation', :with => 'password'
    click_button 'Register'

    wait_until(20) { page.has_content? 'An e-mail was sent to confirm your address' }
    User.last.email.should == 'user123@example.com'
    User.last.confirmation_token.should_not be_nil
  end

  scenario 'confirms the e-mail of new registered user', js: true do
    user = FactoryGirl.create :user
    visit root_path + "/#/login?confirmation_token=#{user.confirmation_token}"
    page.should have_content "Your e-mail is now confirmed, please sign in."
  end

  scenario 'logs in with new registered user', js: true do
    user = FactoryGirl.create :user
    user.update_attribute :confirmation_token, nil
    visit root_path
    fill_in 'email', :with => user.email
    fill_in 'password', :with => 'secret123'
    click_button 'Sign in!'
    page.should have_content "Projects"
  end

  scenario 'display "Register" header on registration screen', js: true do
    visit root_path
    click_link 'Register'
    page.should have_selector('h4', text: "Register")
  end

end
