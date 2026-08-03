#!/bin/bash
# Fetch PR review data (threads, reviews, issue comments, files) via GitHub GraphQL API.
# Usage: pr-fetch-reviews.sh <owner> <repo> <pr-number>
set -euo pipefail

owner="${1:?Usage: pr-fetch-reviews.sh <owner> <repo> <pr-number>}"
repo="${2:?Usage: pr-fetch-reviews.sh <owner> <repo> <pr-number>}"
pr="${3:?Usage: pr-fetch-reviews.sh <owner> <repo> <pr-number>}"

gh api graphql -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      number
      title
      url
      author { login }
      files(first: 100) {
        nodes {
          path
        }
      }
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          path
          line
          startLine
          diffSide
          comments(first: 10) {
            nodes {
              id
              databaseId
              fullDatabaseId
              replyTo {
                id
              }
              url
              body
              author { login }
              createdAt
            }
          }
        }
      }
      reviews(first: 100) {
        nodes {
          id
          url
          body
          state
          submittedAt
          isMinimized
          viewerCanMinimize
          author { login }
          comments(first: 1) {
            totalCount
          }
        }
      }
      comments(first: 100) {
        nodes {
          id
          databaseId
          fullDatabaseId
          url
          body
          createdAt
          updatedAt
          isMinimized
          viewerCanMinimize
          author { login }
        }
      }
    }
  }
}' -f owner="$owner" -f repo="$repo" -F pr="$pr"
