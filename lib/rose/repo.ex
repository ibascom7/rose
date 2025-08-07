defmodule Rose.Repo do
  use Ecto.Repo,
    otp_app: :rose,
    adapter: Ecto.Adapters.Postgres
end
