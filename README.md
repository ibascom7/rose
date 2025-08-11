# Rose

## Pages

- /home:
   - Big picture overview and pictures
- /about:
   - History and goals of org
- /donate:
   - page with info about our campaigns and what donations would go towards.
   - donation button link to https://donorbox.org/crusade-for-freedom
- /events:
   - info on upcoming events 
   - RSVP button to get emails on how to participate
- /articles
   - regular newsletter that is also posted onto the site

## Development Setup

### Option 1: Docker (Recommended)
```bash
# Clone and start everything
git clone <your-repo-url>
cd rose
docker-compose up -d

# View logs
docker-compose logs -f web
```

Visit [`localhost:4000`](http://localhost:4000) from your browser.

### Option 2: Local Development
* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production Deployment

### Railway
1. Connect your GitHub repo to Railway
2. Set environment variables:
   - `SECRET_KEY_BASE` (generate with `mix phx.gen.secret`)
   - `DATABASE_URL` (Railway will provide this)
   - `PHX_HOST` (your Railway domain)
3. Railway will automatically build using `Dockerfile.prod`

### Docker Production
```bash
docker-compose -f docker-compose.prod.yml up -d
```

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
