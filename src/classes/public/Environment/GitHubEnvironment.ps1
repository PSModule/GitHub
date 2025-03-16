class RequiredReviewers {
    [int]$Id
    [string]$NodeId
    [bool]$PreventSelfReview
    [string]$Reviewers

    RequiredReviewers([psobject]$data) {
        $this.Id = $data.id
        $this.NodeId = $data.node_id
        $this.PreventSelfReview = $data.prevent_self_review
        $this.Reviewers = $data.reviewers
    }
}

class BranchPolicy {
    [int]$Id
    [string]$NodeId

    BranchPolicy([psobject]$data) {
        $this.Id = $data.id
        $this.NodeId = $data.node_id
    }
}

class DeploymentBranchPolicy {
    [bool]$ProtectedBranches
    [bool]$CustomBranchPolicies

    DeploymentBranchPolicy([psobject]$data) {
        $this.ProtectedBranches = $data.protected_branches
        $this.CustomBranchPolicies = $data.custom_branch_policies
    }
}

class Environment {
    [long]$Id
    [string]$NodeId
    [string]$Name
    [string]$Url
    [string]$HtmlUrl
    [datetime]$CreatedAt
    [datetime]$UpdatedAt
    [bool]$CanAdminsBypass

    [RequiredReviewers]$RequiredReviewers
    [BranchPolicy]$BranchPolicy
    [DeploymentBranchPolicy]$DeploymentBranchPolicy

    Environment([psobject]$data) {
        $this.Id = $data.id
        $this.NodeId = $data.node_id
        $this.Name = $data.name
        $this.Url = $data.url
        $this.HtmlUrl = $data.html_url
        $this.CreatedAt = [datetime]$data.created_at
        $this.UpdatedAt = [datetime]$data.updated_at
        $this.CanAdminsBypass = $data.can_admins_bypass

        foreach ($rule in $data.protection_rules) {
            switch ($rule.type) {
                'required_reviewers' { $this.RequiredReviewers = [RequiredReviewers]::new($rule) }
                'branch_policy' { $this.BranchPolicy = [BranchPolicy]::new($rule) }
            }
        }

        $this.DeploymentBranchPolicy = [DeploymentBranchPolicy]::new($data.deployment_branch_policy)
    }
}
