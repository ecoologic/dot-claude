# Next.js - Docs

This reference covers PostHog feature flags in a [Next.js](https://nextjs.org/) app.

Assumes `posthog-js` and `posthog-node` are already installed and initialised.

> You can see a working example of this integration in our [Next.js demo app](https://github.com/PostHog/posthog-js/tree/main/playground/nextjs).

Covers client-side hooks plus server-side flag evaluation in both the app and pages routers.

> **Try `@posthog/next` (pre-release):** A simplified Next.js integration with synchronized client/server identity, server-side flag bootstrapping, and a built-in API proxy. [Read the setup guide →](/docs/libraries/next-js/posthog-next.md)

## Bootstrapping flags with `instrumentation-client`

When using `instrumentation-client`, the values you pass to `posthog.init` remain fixed for the entire session. This means bootstrapping only works if you evaluate flags **before your app renders** (for example, on the server).

If you need flag values after the app has rendered, you’ll want to:

-   Evaluate the flag on the server and pass the value into your app, or
-   Evaluate the flag in an earlier page/state, then store and re-use it when needed.

Both approaches avoid flicker and give you the same outcome as bootstrapping, as long as you use the same `distinct_id` across client and server.

See the [bootstrapping guide](/docs/feature-flags/bootstrapping.md) for more information.

## Using React hooks

The [React feature flag hooks](/docs/libraries/react.md#feature-flags) work automatically when PostHog is initialized via `instrumentation-client.ts`. The hooks use the initialized posthog-js singleton:

JavaScript

PostHog AI

```javascript
'use client'
import { useFeatureFlagEnabled } from 'posthog-js/react'
export default function FeatureComponent() {
  const showNewFeature = useFeatureFlagEnabled('new-feature')
  return showNewFeature ? <NewFeature /> : <OldFeature />
}
```

## App router

For the app router, we can initialize the `posthog-node` SDK once with a `PostHogClient` function, and import it into files.

This enables us to evaluate flags and fetch data from PostHog on the server – without making client-side requests.

JavaScript

PostHog AI

```javascript
// app/posthog.js
import { PostHog } from 'posthog-node'
export default function PostHogClient() {
  const posthogClient = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_TOKEN, {
    host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    flushAt: 1,
    flushInterval: 0
  })
  return posthogClient
}
```

> **Note:** Because server-side functions in Next.js can be short-lived, we set `flushAt` to `1` and `flushInterval` to `0`.
>
> -   `flushAt` sets how many capture calls we should flush the queue (in one batch).
> -   `flushInterval` sets how many milliseconds we should wait before flushing the queue. Setting them to the lowest number ensures events are sent immediately and not batched. We also need to call `await posthog.shutdown()` once done.

To use this client, we import it into our pages and call it with the `PostHogClient` function:

JavaScript

PostHog AI

```javascript
import Link from 'next/link'
import PostHogClient from '../posthog'
export default async function About() {
  const posthog = PostHogClient()
  const flags = await posthog.getAllFlags(
    'user_distinct_id' // replace with a user's distinct ID
  );
  await posthog.shutdown()
  return (
    <main>
      <h1>About</h1>
      <Link href="/">Go home</Link>
      { flags['main-cta'] &&
        <Link href="http://posthog.com/">Go to PostHog</Link>
      }
    </main>
  )
}
```

## Pages router

For the pages router, we can use the `getServerSideProps` function to evaluate feature flags on the server-side.

This looks like this:

JavaScript

PostHog AI

```javascript
// pages/posts/[id].js
import { useContext, useEffect, useState } from 'react'
import { getServerSession } from "next-auth/next"
import { PostHog } from 'posthog-node'
export default function Post({ post, flags }) {
  const [ctaState, setCtaState] = useState()
  useEffect(() => {
    if (flags) {
      setCtaState(flags['blog-cta'])
    }
  })
  return (
    <div>
      <h1>{post.title}</h1>
      <p>By: {post.author}</p>
      <p>{post.content}</p>
      {ctaState &&
        <p><a href="/">Go to PostHog</a></p>
      }
      <button onClick={likePost}>Like</button>
    </div>
  )
}
export async function getServerSideProps(ctx) {
  const session = await getServerSession(ctx.req, ctx.res)
  let flags = null
  if (session) {
    const client = new PostHog(
      process.env.NEXT_PUBLIC_POSTHOG_TOKEN,
      {
        host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
      }
    )
    flags = await client.getAllFlags(session.user.email);
    client.capture({
      distinctId: session.user.email,
      event: 'loaded blog article',
      properties: {
        $current_url: ctx.req.url,
      },
    });
    await client.shutdown()
  }
  const { posts } = await import('../../blog.json')
  const post = posts.find((post) => post.id.toString() === ctx.params.id)
  return {
    props: {
      post,
      flags
    },
  }
}
```

> **Note**: Make sure to *always* call `await client.shutdown()` after sending events from the server-side. PostHog queues events into larger batches, and this call forces all batched events to be flushed immediately.

### Server-side configuration

Next.js overrides the default `fetch` behavior on the server to introduce their own cache. PostHog ignores that cache by default, as this is Next.js's default behavior for any fetch call.

You can override that configuration when initializing PostHog, but make sure you understand the pros/cons of using Next.js's cache and that you might get cached results rather than the actual result our server would return. This is important for feature flags, for example.

TSX

PostHog AI

```jsx
posthog.init(process.env.NEXT_PUBLIC_POSTHOG_TOKEN, {
  // ... your configuration
  fetch_options: {
    cache: 'force-cache', // Use Next.js cache
    next_options: {       // Passed to the `next` option for `fetch`
      revalidate: 60,     // Cache for 60 seconds
      tags: ['posthog'],  // Can be used with Next.js `revalidateTag` function
    },
  }
})
```

