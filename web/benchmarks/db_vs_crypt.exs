alias Ogahunt.Accounts
require Ecto.Query

Benchee.run(
  %{
    "Auth: with password check" => fn ->
      Accounts.auth_user("test@test.com", "123456")
    end,
    "Auth: DB only" => fn ->
      Accounts.get_user_by_email("test@test.com")
    end
  },
  time: 10,
  warmup: 5,
  formatters: [
    &Benchee.Formatters.Console.output/1,
    &Benchee.Formatters.HTML.output/1
  ],
  html: [file: "benchmarks/reports/latest_general.html"]
)
