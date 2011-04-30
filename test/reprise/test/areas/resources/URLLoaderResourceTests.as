/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package reprise.test.areas.resources
{
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.hasPropertyWithValue;

	import reprise.commands.events.CommandEvent;

	import reprise.resources.URLLoaderResource;
	import reprise.resources.events.ResourceEvent;

	public class URLLoaderResourceTests
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//
		private var _resource : URLLoaderResource;


		//----------------------               Public Methods               ----------------------//
		[Test(expects='Error')] public function invokingLoadWithoutURLThrows() : void
		{
			_resource = new URLLoaderResource('');
			_resource.load();
		}
		[Test] public function invokingLoadSetsExecutingFlag() : void
		{
			_resource = new URLLoaderResource('doesn\'t matter');
			_resource.load();
			assertThat(_resource, hasPropertyWithValue('isExecuting', true));
			_resource.cancel();
		}
		[Test] public function invokingCancelAfterLoadResetsExecutingFlag() : void
		{
			_resource = new URLLoaderResource('doesn\'t matter');
			_resource.load();
			_resource.cancel();
			assertThat(_resource, hasPropertyWithValue('isExecuting', false));
		}
		[Test(async)] public function urlLoaderCompletesWhenLoadingNonExistingLocalFile() : void
		{
			_resource = new URLLoaderResource('foo.bar');
			Async.handleEvent(this, _resource, CommandEvent.COMPLETE,
					urlLoaderCompletesWhenLoadingNonExistingLocalFile_result, 5000);
			_resource.load();
		}
		private function urlLoaderCompletesWhenLoadingNonExistingLocalFile_result(...args) : void
		{
			//no need to assert anything here, this method is only needed to make Flexunit happy
		}
		[Test(async)]
		public function urlLoaderCompletesWithIOErrorWhenLoadingNonExistingLocalFile() : void
		{
			_resource = new URLLoaderResource('foo.bar');
			Async.handleEvent(this, _resource, CommandEvent.COMPLETE,
					urlLoaderCompletesWithIOErrorWhenLoadingNonExistingLocalFile_result, 5000);
			_resource.load();
		}
		private function urlLoaderCompletesWithIOErrorWhenLoadingNonExistingLocalFile_result(
				event : ResourceEvent, rest : Object) : void
		{
			assertThat(event, hasPropertyWithValue('error', ResourceEvent.ERROR_IO));
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}