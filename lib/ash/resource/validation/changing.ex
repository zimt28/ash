defmodule Ash.Resource.Validation.Changing do
  @moduledoc false
  alias Ash.Error.Changes.InvalidAttribute

  use Ash.Resource.Validation

  @opt_schema [
    field: [
      type: :atom,
      required: true,
      doc: "The attribute to check"
    ]
  ]

  @impl true
  def init(opts) do
    case Ash.OptionsHelpers.validate(opts, @opt_schema) do
      {:ok, opts} ->
        {:ok, opts}

      {:error, error} ->
        {:error, Exception.message(error)}
    end
  end

  @impl true
  def validate(changeset, opts) do
    case Ash.Resource.Info.relationship(changeset.resource, opts[:field]) do
      nil ->
        if Ash.Changeset.changing_attribute?(changeset, opts[:field]) do
          :ok
        else
          {:error,
           InvalidAttribute.exception(
             field: opts[:field],
             message: "must be changing"
           )}
        end

      %{type: :belongs_to, source_field: source_field} = relationship ->
        if Ash.Changeset.changing_attribute?(changeset, source_field) ||
             Ash.Changeset.changing_relationship?(changeset, relationship.name) do
          :ok
        else
          {:error,
           InvalidAttribute.exception(
             field: opts[:field],
             message: "must be changing"
           )}
        end

      relationship ->
        if Ash.Changeset.changing_relationship?(changeset, relationship.name) do
          :ok
        else
          {:error,
           InvalidAttribute.exception(
             field: opts[:field],
             message: "must be changing"
           )}
        end
    end
  end
end
