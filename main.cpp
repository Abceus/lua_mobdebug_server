//
// refactored_echo_server.cpp
// ~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2022 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#include <asio/co_spawn.hpp>
#include <asio/detached.hpp>
#include <asio/io_context.hpp>
#include <asio/ip/tcp.hpp>
#include <asio/signal_set.hpp>
#include <asio/write.hpp>
#include <asio/streambuf.hpp>
#include <asio/read_until.hpp>
#include <asio/buffer.hpp>
#include <cstdio>
#include <iostream>
#include <codecvt>

using asio::ip::tcp;
using asio::awaitable;
using asio::co_spawn;
using asio::detached;
using asio::use_awaitable;
namespace this_coro = asio::this_coro;

bool connectFinished = false;

awaitable<void> listen(tcp::socket& socket)
{
	std::string step = "STEP\n";
  	co_await async_write(socket, asio::dynamic_buffer(step), use_awaitable);
	std::string read_msg;
	co_await asio::async_read_until(socket,
				asio::dynamic_buffer(read_msg), "\n", use_awaitable);
    std::cout << read_msg << std::endl;
	std::string read_msg2;
	co_await asio::async_read_until(socket,
				asio::dynamic_buffer(read_msg2), "\n", use_awaitable);
    std::cout << read_msg2 << std::endl;
	connectFinished = true;
}

awaitable<void> handle(tcp::socket& socket, const std::string& command)
{
	auto resultCommand = command + '\n';
	std::cout << resultCommand << std::endl;
  	co_await async_write(socket, asio::dynamic_buffer(resultCommand), use_awaitable);
	//   while(true) {
		std::string read_msg;
		// char data[1024];
		// co_await socket.async_read_some(asio::buffer(data), use_awaitable);
		co_await asio::async_read_until(socket,
					asio::dynamic_buffer(read_msg), "\n", use_awaitable);
		std::cout << read_msg << std::endl;
	//   }
}

awaitable<void> echo(tcp::socket socket)
{
  try
  {
	while (!connectFinished)
	{
	  // The asynchronous operations to echo a single chunk of data have been
	  // refactored into a separate function. When this function is called, the
	  // operations are still performed in the context of the current
	  // coroutine, and the behaviour is functionally equivalent.
	  co_await listen(socket);
	}
	while (true)
	{
	  	std::string command;
		std::getline(std::cin, command);
	  	co_await handle(socket, command);
	}
  }
  catch (std::exception& e)
  {
	std::printf("echo Exception: %s\n", e.what());
  }
}

awaitable<void> listener()
{
  auto executor = co_await this_coro::executor;
  tcp::acceptor acceptor(executor, {tcp::v4(), 8172});
  for (;;)
  {
	tcp::socket socket = co_await acceptor.async_accept(use_awaitable);
	co_spawn(executor, echo(std::move(socket)), detached);
  }
}

int main()
{
  try
  {
	asio::io_context io_context(1);

	asio::signal_set signals(io_context, SIGINT, SIGTERM);
	signals.async_wait([&](auto, auto){ io_context.stop(); });

	co_spawn(io_context, listener(), detached);

	io_context.run();
  }
  catch (std::exception& e)
  {
	std::printf("Exception: %s\n", e.what());
  }
}