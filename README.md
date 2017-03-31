## Jupyterhub with dummyauthenticator and set of ML libs (like tensorflow) for tests


### Building
`
docker build -t codeabovelab/jupyterhub .
`

NB: image exists in dockerhub

`
docker pull codeabovelab/jupyterhub
`
### Running
`
docker run -d -p 8754:8754 --name jupyterhub codeabovelab/jupyterhub
`

use admin with no password 

### Testing

`
import tensorflow as tf

hello = tf.Variable('Hello World!')

sess = tf.Session()

init = tf.initialize_all_variables()

sess.run(init)

sess.run(hello)
`
