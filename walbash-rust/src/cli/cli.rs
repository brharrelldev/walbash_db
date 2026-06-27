use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "walbash-cli")]
#[command(version = "0.0.1")]
#[command(about = "cli utility to test and interact with kv store")]
#[command(arg_required_else_help = true)]
pub struct WalBashArgs {
    #[command(subcommand)]
    pub load: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    Load {
        #[arg(long, short)]
        data_file: String,
    },
}
