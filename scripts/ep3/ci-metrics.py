"""Convert the CI run's JaCoCo report and measured deployment into Prometheus gauges."""

import argparse
from xml.etree import ElementTree


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("report")
    parser.add_argument("deployment_seconds", type=int)
    args = parser.parse_args()

    try:
        report = ElementTree.parse(args.report).getroot()
        counter = report.find("./counter[@type='LINE']")
        if report.tag != "report" or counter is None:
            raise ValueError("missing aggregate LINE counter")
        covered = int(counter.attrib["covered"])
        missed = int(counter.attrib["missed"])
        if min(covered, missed) < 0 or covered + missed == 0:
            raise ValueError("invalid JaCoCo line totals")
        if args.deployment_seconds < 0:
            raise ValueError("negative deployment duration")
    except (OSError, ElementTree.ParseError, KeyError, ValueError) as exc:
        parser.error(str(exc))

    coverage = 100 * covered / (covered + missed)
    print("# HELP novabank_ci_line_coverage_percent JaCoCo line coverage from this CI run.")
    print("# TYPE novabank_ci_line_coverage_percent gauge")
    print(f"novabank_ci_line_coverage_percent {coverage:.12g}")
    print("# HELP novabank_ci_deploy_duration_seconds Time from apply to verified Cuentas rollout.")
    print("# TYPE novabank_ci_deploy_duration_seconds gauge")
    print(f"novabank_ci_deploy_duration_seconds {args.deployment_seconds}")


if __name__ == "__main__":
    main()
