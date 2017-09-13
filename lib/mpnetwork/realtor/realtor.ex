defmodule Mpnetwork.Realtor do
  @moduledoc """
  The boundary for the Realtor system.
  """

  import Ecto.Query, warn: false
  alias Mpnetwork.Repo

  alias Mpnetwork.Realtor.{Broadcast, Listing, Office}
  alias Mpnetwork.User

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{email: "test@example.com"})
      {:ok, %User{}}

      iex> create_user(%{email: ""})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(from u in User, order_by: [asc: u.name])
  end

  def list_users(nil) do
    Repo.all(from u in User, order_by: [asc: u.name])
  end

  def list_users(office) do
    Repo.all(from u in User, where: u.office_id == ^office.id, order_by: [asc: u.name])
  end

  @doc """
  Returns the list of broadcasts.

  ## Examples

      iex> list_broadcasts()
      [%Broadcast{}, ...]

  """
  def list_broadcasts do
    Repo.all(Broadcast) #|> Repo.preload(:user)
  end

  @doc """
  Returns the last N broadcasts, sorted descending.

  ## Examples

      iex> list_latest_broadcasts()
      [%Broadcast{}, ...]

  """
  def list_latest_broadcasts(count \\ 5) do
    Repo.all(from b in Broadcast, order_by: [desc: b.inserted_at], limit: ^count) |> Repo.preload(:user)
  end

  @doc """
  Gets a single broadcast.

  Raises `Ecto.NoResultsError` if the Broadcast does not exist.

  ## Examples

      iex> get_broadcast!(123)
      %Broadcast{}

      iex> get_broadcast!(456)
      ** (Ecto.NoResultsError)

  """
  def get_broadcast!(id) do
    Repo.get!(Broadcast, id) #|> Repo.preload(:user)
  end

  def get_broadcast_with_user!(id) do
    Repo.get!(Broadcast, id) |> Repo.preload(:user)
  end

  @doc """
  Creates a broadcast.

  ## Examples

      iex> create_broadcast(%{field: value})
      {:ok, %Broadcast{}}

      iex> create_broadcast(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_broadcast(attrs \\ %{}) do
    %Broadcast{}
    |> Broadcast.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a broadcast.

  ## Examples

      iex> update_broadcast(broadcast, %{field: new_value})
      {:ok, %Broadcast{}}

      iex> update_broadcast(broadcast, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_broadcast(%Broadcast{} = broadcast, attrs) do
    broadcast
    |> Broadcast.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Broadcast.

  ## Examples

      iex> delete_broadcast(broadcast)
      {:ok, %Broadcast{}}

      iex> delete_broadcast(broadcast)
      {:error, %Ecto.Changeset{}}

  """
  def delete_broadcast(%Broadcast{} = broadcast) do
    Repo.delete(broadcast)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking broadcast changes.

  ## Examples

      iex> change_broadcast(broadcast)
      %Ecto.Changeset{source: %Broadcast{}}

  """
  def change_broadcast(%Broadcast{} = broadcast) do
    Broadcast.changeset(broadcast, %{})
  end

  alias Mpnetwork.Realtor.Listing

  @doc """
  Returns the list of listings.

  ## Examples

      iex> list_listings()
      [%Listing{}, ...]

  """

  def list_listings(realtor, limit \\ 30) do
    list_latest_listings(realtor, limit)
  end


  def list_latest_listings(who, limit \\ 5)

  @doc """
  Returns the latest non-draft listings by everyone

  ## Examples

      iex> list_listings()
      [%Listing{}, ...]

  """
  def list_latest_listings(nil, limit) do
    Repo.all(from l in Listing, where: l.draft == false, order_by: [desc: l.inserted_at], limit: ^limit)
  end

  @doc """
  Returns the latest listings by this user

  ## Examples

      iex> list_listings()
      [%Listing{}, ...]

  """
  def list_latest_listings(current_user, limit) do
    Repo.all(from l in Listing, where: l.user_id == ^current_user.id, order_by: [desc: l.inserted_at], limit: ^limit)
  end

  @doc """
  Gets a single listing.

  Raises `Ecto.NoResultsError` if the Listing does not exist.

  ## Examples

      iex> get_listing!(123)
      %Listing{}

      iex> get_listing!(456)
      ** (Ecto.NoResultsError)

  """
  def get_listing!(id), do: Repo.get!(Listing, id) |> Repo.preload([:broker, :user])

  @doc """
  Creates a listing.

  ## Examples

      iex> create_listing(%{field: value})
      {:ok, %Listing{}}

      iex> create_listing(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_listing(attrs \\ %{}) do
    %Listing{}
    |> Listing.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a listing.

  ## Examples

      iex> update_listing(listing, %{field: new_value})
      {:ok, %Listing{}}

      iex> update_listing(listing, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_listing(%Listing{} = listing, attrs) do
    listing
    |> Listing.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Listing.

  ## Examples

      iex> delete_listing(listing)
      {:ok, %Listing{}}

      iex> delete_listing(listing)
      {:error, %Ecto.Changeset{}}

  """
  def delete_listing(%Listing{} = listing) do
    Repo.delete(listing)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking listing changes.

  ## Examples

      iex> change_listing(listing)
      %Ecto.Changeset{source: %Listing{}}

  """
  def change_listing(%Listing{} = listing) do
    Listing.changeset(listing, %{})
  end

  @doc """
  Returns a list of all office names with their id's.
  """
  def all_office_names do
    Repo.all(
      from office in Office,
      select: {office.id, office.name},
      order_by: [desc: office.name]
    )
  end

  @doc """
  Returns the list of offices.

  ## Examples

      iex> list_offices()
      [%Office{}, ...]

  """
  def list_offices do
    Repo.all(
      from office in Office,
      order_by: [desc: office.name]
    )
  end

  @doc """
  Gets a single office.

  Raises `Ecto.NoResultsError` if the Office does not exist.

  ## Examples

      iex> get_office!(123)
      %Office{}

      iex> get_office!(456)
      ** (Ecto.NoResultsError)

  """
  def get_office!(id), do: Repo.get!(Office, id)

  @doc """
  Creates a office.

  ## Examples

      iex> create_office(%{field: value})
      {:ok, %Office{}}

      iex> create_office(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_office(attrs \\ %{}) do
    %Office{}
    |> Office.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a office.

  ## Examples

      iex> update_office(office, %{field: new_value})
      {:ok, %Office{}}

      iex> update_office(office, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_office(%Office{} = office, attrs) do
    office
    |> Office.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Office.

  ## Examples

      iex> delete_office(office)
      {:ok, %Office{}}

      iex> delete_office(office)
      {:error, %Ecto.Changeset{}}

  """
  def delete_office(%Office{} = office) do
    Repo.delete(office)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking office changes.

  ## Examples

      iex> change_office(office)
      %Ecto.Changeset{source: %Office{}}

  """
  def change_office(%Office{} = office) do
    Office.changeset(office, %{})
  end
end
