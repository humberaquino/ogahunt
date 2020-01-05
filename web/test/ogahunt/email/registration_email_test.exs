defmodule Ogahunt.RegistrationEmailTest do
  use ExUnit.Case
  # use Bamboo.Test
  use Bamboo.Test, shared: true

  alias Ogahunt.RegistrationEmail

  test "registration email" do
    to_email = "test@test.com"
    token = "1234567890"
    assert_delivered_email(RegistrationEmail.send_token_email(to_email, token))
  end

  # test "after registering, the user gets a welcome email" do
  #   # Integration test with the helpers from Bamboo.Test
  #   user = new_user

  #   MyApp.Register(user)

  #   assert_delivered_email MyApp.Email.welcome_email(user)
  # end
end
