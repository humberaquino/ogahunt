defmodule Ogahunt.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Ogahunt.Repo

  alias Ogahunt.Contacts.Contact
  alias Ogahunt.Estates.Estate

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts do
    Repo.all(Contact)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    # Add default version number
    attrs = Map.put(attrs, "version", 1)

    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  

  @doc """
  Deletes a Contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end

  def list_team_contacts(team_id) do
    query = from(c in Contact, where: c.team_id == ^team_id and c.is_deleted == false)
    Repo.all(query)
  end

  def mark_as_deleted(%Contact{} = contact, user_id) do
    # Check if the contact hast at least one non-deleted estate
    if has_active_estate_associated(contact) do
      {:error, "Has active estates associated"}
    else
      contact
      |> Contact.delete_changeset(%{is_deleted: true, updated_by_id: user_id})
      |> Repo.update!()

      {:ok, contact}
    end
  end

  def has_active_estate_associated(%Contact{} = contact) do
    query =
      from(e in Estate,
        where: e.main_contact_id == ^contact.id and e.is_deleted == false,
        limit: 1
      )

    res = Repo.all(query)
    Enum.count(res) > 0
  end
end
