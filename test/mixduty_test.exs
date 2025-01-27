defmodule MixdutyTest do
  use ExUnit.Case
  doctest Mixduty

  describe "handle_response" do
    @success_json """
    {
    "incident": {
        "id": "PT4KHLK",
        "type": "incident",
        "summary": "[#1234] The server is on fire.",
        "self": "https://api.pagerduty.com/incidents/PT4KHLK",
        "html_url": "https://subdomain.pagerduty.com/incidents/PT4KHLK",
        "incident_number": 1234,
        "created_at": "2015-10-06T21:30:42Z",
        "status": "resolved",
        "pending_actions": [
            {
                "type": "unacknowledge",
                "at": "2015-11-10T01:02:52Z"
            },
            {
                "type": "resolve",
                "at": "2015-11-10T04:31:52Z"
            }
        ],
        "incident_key": "baf7cf21b1da41b4b0221008339ff357",
        "service": {
            "id": "PIJ90N7",
            "type": "generic_email",
            "summary": "My Mail Service",
            "self": "https://api.pagerduty.com/services/PIJ90N7",
            "html_url": "https://subdomain.pagerduty.com/services/PIJ90N7"
        },
        "assigned_via": "escalation_policy",
        "assignments": [
            {
                "at": "2015-11-10T00:31:52Z",
                "assignee": {
                    "id": "PXPGF42",
                    "type": "user_reference",
                    "summary": "Earline Greenholt",
                    "self": "https://api.pagerduty.com/users/PXPGF42",
                    "html_url": "https://subdomain.pagerduty.com/users/PXPGF42"
                }
            }
        ],
        "acknowledgements": [
            {
                "at": "2015-11-10T00:32:52Z",
                "acknowledger": {
                    "id": "PXPGF42",
                    "type": "user_reference",
                    "summary": "Earline Greenholt",
                    "self": "https://api.pagerduty.com/users/PXPGF42",
                    "html_url": "https://subdomain.pagerduty.com/users/PXPGF42"
                }
            }
        ],
        "last_status_change_at": "2015-10-06T21:38:23Z",
        "last_status_change_by": {
            "id": "PXPGF42",
            "type": "user_reference",
            "summary": "Earline Greenholt",
            "self": "https://api.pagerduty.com/users/PXPGF42",
            "html_url": "https://subdomain.pagerduty.com/users/PXPGF42"
        },
        "first_trigger_log_entry": {
            "id": "Q02JTSNZWHSEKV",
            "type": "trigger_log_entry_reference",
            "summary": "Triggered through the API",
            "self": "https://api.pagerduty.com/log_entries/Q02JTSNZWHSEKV?incident_id=PT4KHLK",
            "html_url": "https://subdomain.pagerduty.com/incidents/PT4KHLK/log_entries/Q02JTSNZWHSEKV"
        },
        "escalation_policy": {
            "id": "PT20YPA",
            "type": "escalation_policy_reference",
            "summary": "Another Escalation Policy",
            "self": "https://api.pagerduty.com/escalation_policies/PT20YPA",
            "html_url": "https://subdomain.pagerduty.com/escalation_policies/PT20YPA"
        },
        "teams": [
            {
                "id": "PQ9K7I8",
                "type": "team_reference",
                "summary": "Engineering",
                "self": "https://api.pagerduty.com/teams/PQ9K7I8",
                "html_url": "https://subdomain.pagerduty.com/teams/PQ9K7I8"
            }
        ],
        "urgency": "high"
    }
    }
    """

    test "parses a successful response" do
      response = {:ok, %HTTPoison.Response{status_code: 201, body: @success_json}}

      assert {:ok,
              %Mixduty.Response{
                body: %{"incident" => %{"summary" => "[#1234] The server is on fire."}},
                status_code: 201
              }} = Mixduty.Response.new(response)
    end

    test "parses an empty response" do
      response = {:ok, %HTTPoison.Response{status_code: 201, body: ""}}

      assert {:ok,
              %Mixduty.Response{
                body: %{},
                status_code: 201
              }} = Mixduty.Response.new(response)
    end

    test "errors on failure to parse JSON" do
      response =
        {:ok,
         %HTTPoison.Response{
           status_code: 201,
           body: """
           {"Incomplete": "respon
           """
         }}

      assert {:error, %Mixduty.Error{message: message, status_code: 201, cause: _}} =
               Mixduty.Response.new(response)

      assert String.starts_with?(message, "JSON parse error: unexpected byte at position")
    end

    test "passes through server errors" do
      response = {:ok, %HTTPoison.Response{status_code: 400, body: "Bad Request"}}

      assert {:error, %Mixduty.Error{message: "Bad Request", status_code: 400, cause: _}} =
               Mixduty.Response.new(response)
    end
  end
end
