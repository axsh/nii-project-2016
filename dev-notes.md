## rough notes, probably best viewed as plain text (i.e. not markdown)

   * adding tasks (coursework) to the existing notebooks

   * break image build script into multiple tasks (but still one job)
     *  start here because it covered more by the old pdfs
     
   * mussel tutorial notebook.

   * translate rpm PDF reference into jupyter

   * translate yum PDF reference into jupyter

   * break integration test into separate jobs
        (web) (deb) (lb) -> three instance start jobs
	(integration test itself)
	(destroy 3 instances)
	(destroy 3 images??)
	
   * Make hipchat account
      if this is a jupyter notebook, then the last cells could test hipchat api, authorization, etc.

   * Make github account.
      if this is a jupyter notebook, then some type of test.


   * Add exercises at the end of the rspec notebook to play with the job for a bit
      (but what about playing with parameters?)



what is interesting?

automatic! works by itself. "how do we get it to run atomically?"  ans: jenkins! rpm!

bash techniques.

test things in cloud enviroments. in parallel.

mechanisms behind yum.

Note: many parts of existing scripts are too complicated for students, unless this
is a class in obscure bash techniques.

