Describe 'Get-GitHubRepository' {
    It 'Function exists' {
        Get-Command Get-GitHubRepository | Should -Not -BeNullOrEmpty
    }

    Context 'Parameter Set: MyRepos_Type' {
        It 'Can be called with no parameters' {
            { Get-GitHubRepository } | Should -Not -Throw
        }

        It 'Can be called with Type parameter' {
            { Get-GitHubRepository -Type 'owner' } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: MyRepos_Aff-Vis' {
        It 'Can be called with Visibility and Affiliation parameters' {
            { Get-GitHubRepository -Visibility 'public' -Affiliation 'owner' } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: ByName' {
        It 'Can be called with Owner and Repo parameters' {
            { Get-GitHubRepository -Owner 'PSModule' -Repo 'GitHub' } | Should -Not -Throw
        }
    }

    # Context 'Parameter Set: ListByID' {
    #     It 'Can be called with SinceID parameter' {
    #         { Get-GitHubRepository -SinceID 123456789 } | Select-Object -First 10 | Should -Not -Throw
    #     }
    # }

    Context 'Parameter Set: ListByOrg' {
        It 'Can be called with Owner parameter' {
            { Get-GitHubRepository -Owner 'PSModule' } | Should -Not -Throw
        }
    }

    Context 'Parameter Set: ListByUser' {
        It 'Can be called with Username parameter' {
            { Get-GitHubRepository -Username 'MariusStorhaug' } | Should -Not -Throw
        }
    }
}
