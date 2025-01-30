terraform {
  backend "s3" {
    bucket         = "tf-infra-task1"
    key            = "task2/tf.state"
    region         = "us-east-1"
  }
}
